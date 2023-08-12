import 'package:flutter/material.dart';
import 'user_model.dart';
import 'api_service.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.fetchAdditionalUserInfo(
            user.id), // Отримання додаткової інформації
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            final additionalInfo = <String, dynamic>{};
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
                  Text('Position: ${additionalInfo['position']}'),
                  // Додаткові дані тут
                ],
              ),
            );
          } else {
            final additionalInfo = snapshot.data!;
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
                  Text('Position: ${additionalInfo['position']}'),
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
