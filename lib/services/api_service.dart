import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  static Future<List<Landmark>> fetchLandmarks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Landmark.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load landmarks');
      }
    } catch (e) {
      throw Exception('Error fetching landmarks: $e');
    }
  }

  static Future<int> createLandmark({
    required String title,
    required double lat,
    required double lon,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['title'] = title;
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();

      if (imageFile != null) {
        final resizedBytes = await _resizeImage(imageFile);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            resizedBytes,
            filename: 'upload.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final idValue = data['id'];
        final parsedId = int.tryParse(idValue.toString()) ?? 0;
        if (parsedId == 0) {
          throw Exception('Invalid create response');
        }
        return parsedId;
      } else {
        throw Exception('Failed to create landmark');
      }
    } catch (e) {
      throw Exception('Error creating landmark: $e');
    }
  }

  static Future<void> updateLandmark({
    required int id,
    required String title,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id.toString(),
          'title': title,
          'lat': lat.toString(),
          'lon': lon.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update landmark');
      }
    } catch (e) {
      throw Exception('Error updating landmark: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteLandmark(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl?id=$id'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete landmark');
      }
    } catch (e) {
      throw Exception('Error deleting landmark: $e');
    }
  }

  static Future<List<int>> _resizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unsupported image');
    }
    final resized = img.copyResize(
      decoded,
      width: 800,
      height: 600,
      interpolation: img.Interpolation.linear,
    );
    return img.encodeJpg(resized, quality: 85);
  }
}
