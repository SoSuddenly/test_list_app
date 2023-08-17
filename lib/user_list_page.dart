import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_card.dart';
import 'user_model.dart';
import 'api_service.dart';

class UserListController extends GetxController {
  var users = <UserModel>[].obs;
  var currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() async {
    final apiData = await ApiService.fetchUsersWithFallback(currentPage);
    final newUsers = apiData.map((item) => UserModel.fromJson(item)).toList();

    // Перевірка наявності користувача перед додаванням
    for (var newUser in newUsers) {
      if (!users.any((user) => user.id == newUser.id)) {
        users.add(newUser);
      }
    }
    currentPage++;
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
            } else {
              controller.fetchUsers();
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      }),
    );
  }
}
