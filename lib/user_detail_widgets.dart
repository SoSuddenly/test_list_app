import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_model.dart';
import 'api_service.dart';

class UserDetailsWidget extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? additionalInfo;

  UserDetailsWidget({required this.user, this.additionalInfo});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double avatarSize = screenWidth * 2 / 3;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                image: NetworkImage(user.avatarUrl),
                fit: BoxFit.contain,
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
          SizedBox(height: 20),
          Text('ID: ${user.id}'),
          if (additionalInfo != null) ...[
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Додаткова дані: ${additionalInfo!['dop_data']}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
