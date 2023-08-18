import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_card.dart';
import 'user_list_controller.dart'; // Імпортуємо новий контролер

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
