import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService extends GetxController {
  static const String apiUrl = 'https://reqres.in/api';
  static const int totalOfflinePages = 0;

  static Future<void> saveOfflineUsers(List<UserModel> users, int page) async {
    final prefs = await SharedPreferences.getInstance();

    // Отримання раніше збереженого JSON-рядка зі списком користувачів
    final existingDataJson = prefs.getString('offlineData');

    // Створення об'єкта для існуючих офлайн даних
    final existingData = <int, List<UserModel>>{};

    // Перевірка, чи є раніше збережений JSON-рядок
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

    // Збереження списку користувачів для конкретної сторінки
    existingData[page] = users;

    // Перетворення об'єкта в Map зі збереженими даними
    final offlineDataJson = existingData.map((key, value) {
      return MapEntry(
          key.toString(), value.map((user) => user.toJson()).toList());
    });

    // Збереження даних у SharedPreferences
    prefs.setString('offlineData', json.encode(offlineDataJson));

    // Додайте логування для виведення інформації про збережені дані
    print('Saved users for page $page: ${users.length} users');
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
        print('Fetching users online for page $page');
        final response = await http.get(Uri.parse('$apiUrl/users?page=$page'));
        final data = json.decode(response.body)['data'] as List<dynamic>?;

        if (data != null) {
          List<UserModel> users = List<UserModel>.from(
              data.map((item) => UserModel.fromJson(item)));

          // Збереження користувачів для конкретної сторінки
          saveOfflineUsers(users, page);

          // Конвертувати список UserModel у список JSON-представлень користувачів (Map)
          usersData = users.map((user) => user.toJson()).toList();
        }
      } else {
        print('Fetching users offline for page $page');
        // Отримання оновлених даних з локального сховища
        final offlineUsers = await fetchOfflineData(page);

        usersData = offlineUsers.map((user) => user.toJson()).toList();
        print('Fetched users from local storage: ${offlineUsers.length}');
      }
    } catch (e) {
      // Тут відбувається таймаут або помилка при з'єднанні
      print('Error or timeout occurred: $e');
    }

    if (usersData.isEmpty) {
      // Отримання оновлених даних з локального сховища
      final offlineUsers = await fetchOfflineData(page);

      usersData = offlineUsers.map((user) => user.toJson()).toList();
    }

    return usersData;
  }

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

  static Future<int> fetchTotalPages() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data != null) {
        return data['total_pages'] ?? 1;
      } else {
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
