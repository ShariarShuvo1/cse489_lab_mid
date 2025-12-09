import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
