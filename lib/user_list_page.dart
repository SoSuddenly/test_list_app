import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_model.dart';
import 'user_detail_page.dart';
import 'api_service.dart';

class UserListController extends GetxController {
  var users = <UserModel>[].obs;
  var offlineUsers = <UserModel>[].obs;
  var currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchOfflineUsers();
    fetchUsers();
  }

  void fetchUsers() async {
    final apiData = await ApiService.fetchUsers(currentPage);
    final newUsers = apiData.map((item) => UserModel.fromJson(item)).toList();

    users.addAll(newUsers);
    offlineUsers.assignAll(users);
    ApiService.saveOfflineUsers(users);
    currentPage++;
  }

  void fetchOfflineUsers() async {
    final offlineData = await ApiService.fetchOfflineUsers();
    offlineUsers.assignAll(offlineData);
  }
}

class UserListPage extends StatelessWidget {
  final controller = Get.put(UserListController());

  void _clearSharedPreferences() async {
    await ApiService.clearSharedPreferences();
    // Очистити дані у контролерах або перезавантажити сторінку, якщо потрібно
  }

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
              return GestureDetector(
                onTap: () {
                  Get.to(() => UserDetailPage(user: user));
                },
                child: Card(
                    child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: NetworkImage(user.avatarUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Проміжок між зображенням і текстом
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Text(user.email),
                  ],
                )),
              );
            } else {
              controller.fetchUsers();
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearSharedPreferences,
        tooltip: 'Clear SharedPreferences',
        child: Icon(Icons.delete),
      ),
    );
  }
}
