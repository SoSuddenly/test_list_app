import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'internet_utils.dart';

class ApiService extends GetxController {
  static const String apiUrl = 'https://reqres.in/api';

  static const int totalOfflinePages = 1;

  static Future<void> saveOfflineUsers(List<UserModel> users, int page) async {
    final prefs = await SharedPreferences.getInstance();

    final existingDataJson = prefs.getString('offlineData');

    final existingData = <int, List<UserModel>>{};

    // Парсинг раніше збережених даних
    if (existingDataJson != null) {
      final existingDataMap =
          json.decode(existingDataJson) as Map<String, dynamic>;
      existingDataMap.forEach((key, value) {
        final pageNumber = int.parse(key);
        final userList = (value as List<dynamic>)
            .map<UserModel>((item) => UserModel.fromJson(item))
            .toList();
        existingData[pageNumber] = userList;
      });
    }

    existingData[page] = users;

    // Перетворення даних в Map і збереження в SharedPreferences
    final offlineDataJson = existingData.map((key, value) {
      return MapEntry(
          key.toString(), value.map((user) => user.toJson()).toList());
    });
    prefs.setString('offlineData', json.encode(offlineDataJson));

    // Логування збережених даних
    // print('Saved users for page $page: ${users.length} users');
  }

  // Реактивні змінні для статусу отримання додаткової інформації
  RxBool _isFetchingAdditionalInfo = false.obs;
  bool get isFetchingAdditionalInfo => _isFetchingAdditionalInfo.value;

  // Реактивні змінні для перевірки наявності додаткової інформації
  RxBool _hasAdditionalInfo = false.obs;
  bool get hasAdditionalInfo => _hasAdditionalInfo.value;

  // Реактивний Map для додаткової інформації про користувача
  RxMap<String, dynamic> _additionalUserInfo = <String, dynamic>{}.obs;
  Map<String, dynamic> get additionalUserInfo => _additionalUserInfo.value;

  // Метод для отримання додаткової інформації про користувача
  Future<void> fetchAdditionalUserInfo(int userId) async {
    // Встановлюємо прапорець отримання додаткової інформації
    _isFetchingAdditionalInfo.value = true;
    try {
      final response = await http.get(Uri.parse('$apiUrl/users/$userId'));
      final data = json.decode(response.body) as Map<String, dynamic>?;

      if (data != null) {
        _additionalUserInfo.value.assignAll(data);
        _hasAdditionalInfo.value = true;
        // Збереження додаткової інформації локально
        await saveAdditionalUserInfoLocally(userId, data);
      } else {
        _hasAdditionalInfo.value = false;
      }
    } catch (e) {
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

  // Метод для збереження додаткової інформації локально
  Future<void> saveAdditionalUserInfoLocally(
      int userId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('additionalUserInfo_$userId', json.encode(data));
  }

  // Метод для отримання додаткової інформації локально
  Future<Map<String, dynamic>?> fetchAdditionalUserInfoLocally(
      int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('additionalUserInfo_$userId');
    if (userInfoJson != null) {
      return json.decode(userInfoJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Метод для отримання користувачів з можливістю відкату до офлайн даних
  static Future<List<Map<String, dynamic>>> fetchUsersWithFallback(
      int page) async {
    // Список для збереження даних
    List<Map<String, dynamic>> usersData = [];

    try {
      // Перевірка наявності Інтернет-з'єднання
      final hasInternet = await InternetUtils.hasInternetConnection();

      if (hasInternet) {
        // Отримання даних з API
        print('Fetching users online for page $page');
        final response = await http.get(Uri.parse('$apiUrl/users?page=$page'));
        final data = json.decode(response.body)['data'] as List<dynamic>?;
        if (data != null) {
          // Збереження офлайн даних
          List<UserModel> users = List<UserModel>.from(
              data.map((item) => UserModel.fromJson(item)));
          saveOfflineUsers(users, page);
          // Перетворення в JSON-представлення
          usersData = users.map((user) => user.toJson()).toList();
        }
      } else {
        // Отримання даних з локального сховища
        print('Fetching users offline for page $page');
        final offlineUsers = await fetchOfflineData(page);
        usersData = offlineUsers.map((user) => user.toJson()).toList();
        print('Fetched users from local storage: ${offlineUsers.length}');
      }
    } catch (e) {
      // Обробка помилок під час отримання даних
      print('Error or timeout occurred: $e');
    }

    if (usersData.isEmpty) {
      // Отримання даних з локального сховища
      final offlineUsers = await fetchOfflineData(page);
      usersData = offlineUsers.map((user) => user.toJson()).toList();
    }

    return usersData;
  }

  // Метод для отримання офлайн даних для певної сторінки
  static Future<List<UserModel>> fetchOfflineData(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineDataJson = prefs.getString('offlineData');
    if (offlineDataJson != null) {
      final offlineDataMap =
          json.decode(offlineDataJson) as Map<String, dynamic>;
      final userListData = offlineDataMap[page.toString()] as List<dynamic>;
      return userListData
          .map<UserModel>((item) => UserModel.fromJson(item))
          .toList();
    } else {
      return [];
    }
  }

  // Метод для отримання загальної кількості сторінок
  static Future<int> fetchTotalPages() async {
    try {
      // Отримання даних з API
      final response = await http.get(Uri.parse('$apiUrl/users'));
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data != null) {
        return data['total_pages'] ?? 1;
      } else {
        // Відновлення збережених офлайн даних
        final prefs = await SharedPreferences.getInstance();
        final offlineDataJson = prefs.getString('offlineData');
        if (offlineDataJson != null) {
          final offlineDataMap =
              json.decode(offlineDataJson) as Map<String, dynamic>;
          final maxSavedPage = offlineDataMap.keys
              .map(int.parse)
              .reduce((a, b) => a > b ? a : b);
          return maxSavedPage;
        } else {
          return totalOfflinePages;
        }
      }
    } catch (e) {
      // Обробка помилок під час отримання загальної кількості сторінок
      print('Error fetching total pages: $e');
      final prefs = await SharedPreferences.getInstance();
      final offlineDataJson = prefs.getString('offlineData');
      if (offlineDataJson != null) {
        final offlineDataMap =
            json.decode(offlineDataJson) as Map<String, dynamic>;
        final maxSavedPage =
            offlineDataMap.keys.map(int.parse).reduce((a, b) => a > b ? a : b);
        return maxSavedPage;
      } else {
        return totalOfflinePages;
      }
    }
  }
}
