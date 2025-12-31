import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.150.38:5000";

  // ---------------- GET CAMP REQUESTS ----------------
  static Future<List<dynamic>> getCampRequests() async {
    try {
      final response =
      await http.get(Uri.parse("$baseUrl/api/camp/requests"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load camp requests");
      }
    } catch (e) {
      throw Exception("Server error: $e");
    }
  }

  // ---------------- DONATE ITEM ----------------
  static Future<void> donateItem(String requestId, int qty) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/donor/donate-item"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "requestId": requestId,
          "donateQty": qty,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Donation failed");
      }
    } catch (e) {
      throw Exception("Server error: $e");
    }
  }
}
