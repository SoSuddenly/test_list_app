import 'package:get/get.dart';
import 'user_model.dart';
import 'api_service_memory.dart';
import 'package:flutter/material.dart';

class UserListController extends GetxController {
  var users = <UserModel>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  final scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    // Додайте слухача для події прокручування
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreUsers();
      }
    });
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

  void loadMoreUsers() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchUsers();
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
    }
  }
}
