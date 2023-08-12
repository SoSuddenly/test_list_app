import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'user_model.dart';

class ApiService extends GetxController {
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
    final existingUsersJson = prefs.getString('offlineUsers');
    final existingUsers = <UserModel>[];

    if (existingUsersJson != null) {
      final existingUserData = json.decode(existingUsersJson) as List<dynamic>;
      existingUsers
          .addAll(existingUserData.map((item) => UserModel.fromJson(item)));
    }

    final newUserIds = users.map((user) => user.id);
    final filteredExistingUsers =
        existingUsers.where((user) => !newUserIds.contains(user.id)).toList();
    filteredExistingUsers.addAll(users);

    final userJsonList =
        filteredExistingUsers.map((user) => user.toJson()).toList();
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

  RxBool _isFetchingAdditionalInfo = false.obs;
  bool get isFetchingAdditionalInfo => _isFetchingAdditionalInfo.value;

  RxBool _hasAdditionalInfo = false.obs;
  bool get hasAdditionalInfo => _hasAdditionalInfo.value;

  RxMap<String, dynamic> _additionalUserInfo = <String, dynamic>{}.obs;
  Map<String, dynamic> get additionalUserInfo =>
      _additionalUserInfo.value; // Зміна

  Future<void> fetchAdditionalUserInfo(int userId) async {
    _isFetchingAdditionalInfo.value = true;
    try {
      final response = await http.get(Uri.parse('$apiUrl/users/$userId'));
      final data = json.decode(response.body) as Map<String, dynamic>?;

      if (data != null) {
        _additionalUserInfo.value.assignAll(data);
        _hasAdditionalInfo.value = true;
        // Зберегти додаткову інформацію в SharedPreferences
        await saveAdditionalUserInfoLocally(userId, data);
      } else {
        _hasAdditionalInfo.value = false;
      }
    } catch (e) {
      // При помилці, спробуйте отримати інформацію з локального сховища
      final localInfo = await fetchAdditionalUserInfoLocally(userId);
      if (localInfo != null) {
        _additionalUserInfo.value.assignAll(localInfo);
        _hasAdditionalInfo.value = true;
      } else {
        _hasAdditionalInfo.value = false;
      }
      print('Error fetching additional user info: $e');
    } finally {
      _isFetchingAdditionalInfo.value = false;
    }
  }

  Future<void> saveAdditionalUserInfoLocally(
      int userId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('additionalUserInfo_$userId', json.encode(data));
  }

  Future<Map<String, dynamic>?> fetchAdditionalUserInfoLocally(
      int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('additionalUserInfo_$userId');
    if (userInfoJson != null) {
      return json.decode(userInfoJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
