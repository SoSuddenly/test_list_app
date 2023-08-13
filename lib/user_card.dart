import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_model.dart';
import 'user_detail_page.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 20),
            Text(
              '${user.firstName} ${user.lastName}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
