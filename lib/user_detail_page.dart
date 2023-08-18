import 'package:flutter/material.dart';
import 'user_model.dart';
import 'api_service_memory.dart';
import 'user_detail_widgets.dart';
import 'package:get/get.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;
  final bool hasInternet;

  UserDetailPage({required this.user, required this.hasInternet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: GetX<ApiService>(
        init: ApiService(),
        builder: (apiService) {
          return UserDetailsWidget(
            user: user,
            additionalInfo: apiService.hasAdditionalInfo
                ? apiService.additionalUserInfo
                : null,
            hasInternet: hasInternet, // Використання функції
          );
        },
      ),
    );
  }
}
