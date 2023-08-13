import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'api_service.dart';
import 'user_detail_widgets.dart';

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
          return UserDetailsWidget(
            user: user,
            additionalInfo: apiService.hasAdditionalInfo
                ? apiService.additionalUserInfo
                : null,
          );
        },
      ),
    );
  }
}
