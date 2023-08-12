import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'api_service.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: GetX<ApiService>(
        init: ApiService(), // Ініціалізуйте ApiService
        builder: (apiService) {
          if (apiService.isFetchingAdditionalInfo) {
            return Center(child: CircularProgressIndicator());
          } else if (!apiService.hasAdditionalInfo) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                    radius: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(user.email),
                  SizedBox(height: 20),
                  Text('ID: ${user.id}'),
                  // Додаткові дані тут
                ],
              ),
            );
          } else {
            final additionalInfo = apiService.additionalUserInfo;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                    radius: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(user.email),
                  SizedBox(height: 20),
                  Text('ID: ${additionalInfo['id']}'),
                  Text(
                      'Position: ${additionalInfo['position']}'), // Позиція з додатковою інформацією
                  // Додаткові дані тут
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
