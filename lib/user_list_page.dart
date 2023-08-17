import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_card.dart';
import 'user_model.dart';
import 'api_service.dart';

class UserListController extends GetxController {
  var users = <UserModel>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
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

class UserListPage extends StatelessWidget {
  final controller = Get.put(UserListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: Obx(() {
        return GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: controller.users.length + 1,
          itemBuilder: (context, index) {
            if (index < controller.users.length) {
              final user = controller.users[index];
              return UserCard(user: user);
            } else if (controller.currentPage.value <
                controller.totalPages.value) {
              // Якщо ще є сторінки для завантаження, показати індикатор завантаження
              return Center(child: CircularProgressIndicator());
            } else {
              // Якщо досягнута остання сторінка, показати кінець списку або хрест
              return Center(
                child:
                    controller.currentPage.value >= controller.totalPages.value
                        ? Icon(Icons.close)
                        : SizedBox(),
              );
            }
          },
        );
      }),
    );
  }
}
