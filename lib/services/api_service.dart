import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import '../models/landmark.dart';
import 'secrets.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  // Took help from AI to implement this function
  static Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final key = Secrets.googleMapsApiKey;
      if (key.isEmpty) return null;
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${lat.toString()},${lon.toString()}',
        'key': key,
      });
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final formatted = first['formatted_address'];
          if (formatted is String && formatted.isNotEmpty) return formatted;
        }
        return null;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  // Took help from AI to implement this function
  static Future<File?> fetchPlacePhoto(double lat, double lon) async {
    try {
      final key = Secrets.googleMapsApiKey;
      if (key.isEmpty) return null;

      final radii = ['50', '200', '500'];
      List<dynamic>? results;
      Map<String, dynamic>? withPhoto;
      Map<String, dynamic>? nearbyData;
      http.Response? nearbyResp;

      for (final r in radii) {
        final nearbyUri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/nearbysearch/json',
          {
            'location': '${lat.toString()},${lon.toString()}',
            'radius': r,
            'key': key,
          },
        );
        nearbyResp = await http.get(nearbyUri);
        if (nearbyResp.statusCode != 200) {
          continue;
        }
        nearbyData = jsonDecode(nearbyResp.body) as Map<String, dynamic>?;
        results = nearbyData?['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          for (final rmap in results) {
            final map = rmap as Map<String, dynamic>;
            if (map['photos'] != null) {
              withPhoto = map;
              break;
            }
          }
          if (withPhoto != null) break;
        }
      }

      if (results == null || results.isEmpty || withPhoto == null) {
        return null;
      }

      final photos = withPhoto['photos'] as List<dynamic>?;
      if (photos == null || photos.isEmpty) return null;
      final photoRef =
          (photos.first as Map<String, dynamic>)['photo_reference'] as String?;
      if (photoRef == null || photoRef.isEmpty) return null;

      final photoUri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/photo',
        {'maxwidth': '800', 'photoreference': photoRef, 'key': key},
      );
      final photoResp = await http.get(photoUri);
      if (photoResp.statusCode != 200) {
        return null;
      }
      final bytes = photoResp.bodyBytes;
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final resized = img.copyResize(
        decoded,
        width: 800,
        height: 600,
        interpolation: img.Interpolation.linear,
      );
      final jpgBytes = img.encodeJpg(resized, quality: 85);
      final tmp = File(
        '${Directory.systemTemp.path}/cse489_place_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tmp.writeAsBytes(jpgBytes, flush: true);
      return tmp;
    } catch (_) {
      return null;
    }
  }

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

  // Took help from AI to implement this function
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
