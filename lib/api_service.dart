import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_model.dart';

class ApiService {
  static const String apiUrl = 'https://reqres.in/api';

  static Future<List<Map<String, dynamic>>> fetchUsers(int page) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users?page=$page'));
      final data = json.decode(response.body)['data']
          as List<dynamic>?; // Додав "?" для забезпечення нуль-безпечності
      return List<Map<String, dynamic>>.from(data ?? []);
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  static Future<void> saveOfflineUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonList = users.map((user) => user.toJson()).toList();
    prefs.setString('offlineUsers', json.encode(userJsonList));
  }

  static Future<List<UserModel>> fetchOfflineUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineUsersJson = prefs.getString('offlineUsers');

    if (offlineUsersJson != null) {
      final data = json.decode(offlineUsersJson) as List<dynamic>;
      return data.map((item) => UserModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchAdditionalUserInfo(
      int userId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users/$userId'));
      final data = json.decode(response.body) as Map<String,
          dynamic>?; // Додав "?" для забезпечення нуль-безпечності
      return data ?? {};
    } catch (e) {
      print('Error fetching additional user info: $e');
      return {};
    }
  }

  static Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
