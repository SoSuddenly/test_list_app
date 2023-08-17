import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService extends GetxController {
  static const String apiUrl = 'https://reqres.in/api';

  // static Future<List<Map<String, dynamic>>> fetchUsers(int page) async {
  //   try {
  //     final response = await http.get(Uri.parse('$apiUrl/users?page=$page'));
  //     final data = json.decode(response.body)['data']
  //         as List<dynamic>?;
  //     return List<Map<String, dynamic>>.from(data ?? []);
  //   } catch (e) {
  //     print('Error fetching users: $e');
  //     return [];
  //   }
  // }
  static Future<void> saveOfflineUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    // Отримання раніше збереженого JSON-рядка зі списком користувачів
    final existingUsersJson = prefs.getString('offlineUsers');

    // Створення списку для існуючих користувачів
    final existingUsers = <UserModel>[];

    // Перевірка, чи є раніше збережений JSON-рядок
    if (existingUsersJson != null) {
      final existingUserData = json.decode(existingUsersJson) as List<dynamic>;
      existingUsers
          .addAll(existingUserData.map((item) => UserModel.fromJson(item)));
    }

    // Додавання нових користувачів до списку існуючих користувачів
    existingUsers.addAll(users);

    // Перетворення списку UserModel в список JSON-представлень користувачів (Map)
    final userJsonList = existingUsers.map((user) => user.toJson()).toList();

    // Збереження списку JSON-представлень користувачів у SharedPreferences
    prefs.setString('offlineUsers', json.encode(userJsonList));

    // Виведення кількості збережених користувачів
    print('Total users saved offline: ${userJsonList.length}');
  }

  static Future<void> clearOfflineUsers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('offlineUsers'); // Видалити ключ, пов'язаний зі списком
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

  static Future<List<Map<String, dynamic>>> fetchUsersWithFallback(
      int page) async {
    List<Map<String, dynamic>> usersData = [];

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final response = await http.get(Uri.parse('$apiUrl/users?page=$page'));
        final data = json.decode(response.body)['data'] as List<dynamic>?;

        if (data != null) {
          List<UserModel> users = List<UserModel>.from(
              data.map((item) => UserModel.fromJson(item)));

          // Якщо це перша порція користувачів, очистити старий список
          if (page == 1) {
            clearOfflineUsers(); // Очищення старого списку
          }

          // Оновлена логіка збереження користувачів
          saveOfflineUsers(users);

          // Конвертувати список UserModel у список JSON-представлень користувачів (Map)
          usersData = users.map((user) => user.toJson()).toList();
        }
      } else {
        print('No internet connection');
      }
    } catch (e) {
      print('Error fetching users from API: $e');

      // Отримати оновлений список користувачів з локального сховища
      final offlineUsers = await fetchOfflineUsers();
      usersData = offlineUsers.map((user) => user.toJson()).toList();

      print('Fetched users from local storage: ${offlineUsers.length}');
    }

    if (usersData.isEmpty) {
      // Отримати оновлений список користувачів з локального сховища
      final offlineUsers = await fetchOfflineUsers();
      usersData = offlineUsers.map((user) => user.toJson()).toList();
    }

    return usersData;
  }
}
