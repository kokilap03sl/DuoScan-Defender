import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.3:3000';

  // Method to make GET requests to the backend
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body); // Return the decoded response
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Method to make POST requests to the backend
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data), // Send the data as JSON
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body); // Return the decoded response
    } else {
      throw Exception('Failed to send data');
    }
  }

  // Method to make PUT requests to the backend
  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data), // Send the data as JSON
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data');
    }
  }

  static Future<bool> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // Add scanned URL result
  static Future<void> logUrlScan({
    required String deviceId,
    required String url,
    String scanStatus = 'Not Checked',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-url'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'device_id': deviceId,
        'url': url,
        'scan_status': scanStatus,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to log scan result');
    }
  }

  // Check URL safety and update status in database
  static Future<String> checkUrlSafety({
    required String urlId,
    required String url,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-url'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'url_id': urlId,
        'url': url,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] ?? 'Unknown';
    } else {
      // Parse and throw the server's error message for better debugging
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to check URL safety');
      } catch (e) {
        throw Exception('Failed to check URL safety');
      }
    }
  }

  static Future<bool> submitUserFeedback({
    required String deviceId,
    String? message,
    String? rating,
    String? userName,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user_feedback');

    final Map<String, dynamic> payload = {
      'device_id': deviceId,
      if (message != null && message.isNotEmpty) 'message': message,
      if (rating != null && rating.isNotEmpty) 'rating': rating,
      if (userName != null && userName.isNotEmpty) 'user_name': userName,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to submit user feedback: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting user feedback: $e');
      return false;
    }
  }

  static Future<bool> updateManagePermissions({
    required String deviceId,
    required bool beepEnabled,
    required String preferredSearchEngine,
    required bool autoCopyToClipboard,
  }) async {
    final uri = Uri.parse('$baseUrl/api/manage_permissions/update');

    final Map<String, dynamic> payload = {
      'device_id': deviceId,
      'beep_enabled': beepEnabled,
      'preferred_search_engine': preferredSearchEngine,
      'auto_copy_to_clipboard': autoCopyToClipboard,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to update manage permissions: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating manage permissions: $e');
      return false;
    }
  }
}
