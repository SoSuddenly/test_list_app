import 'package:get/get.dart';
import 'user_model.dart';
import 'api_service_memory.dart';

class UserListController extends GetxController {
  var users = <UserModel>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  @override
  void onInit() async {
    super.onInit();
    await initializeTotalPages();
    fetchUsers();
  }

  Future<void> initializeTotalPages() async {
    try {
      // Використовуйте функцію `Future.timeout` для встановлення таймауту
      totalPages.value = await ApiService.fetchTotalPages();
    } catch (e) {
      print(e);
    }
  }

  void fetchUsers() async {
    if (currentPage.value <= totalPages.value) {
      final apiData =
          await ApiService.fetchUsersWithFallback(currentPage.value);
      final newUsers = apiData.map((item) => UserModel.fromJson(item)).toList();

      // Перевірка наявності користувача перед додаванням
      for (var newUser in newUsers) {
        if (!users.any((user) => user.id == newUser.id)) {
          users.add(newUser);
        }
      }

      // Оновлення currentPage за потребою
      if (currentPage.value < totalPages.value) {
        currentPage.value++;
        fetchUsers();
      }
    }
  }
}
