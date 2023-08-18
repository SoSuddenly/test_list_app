import 'package:flutter/material.dart';
import 'image_provider.dart';
import 'user_model.dart';

class UserDetailsWidget extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? additionalInfo;
  final bool hasInternet;

  UserDetailsWidget(
      {required this.user, this.additionalInfo, required this.hasInternet});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double avatarSize = screenWidth * 2 / 3;

    ImageProvider imageProvider = getImageProvider(user.avatarUrl, hasInternet);

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
                image: imageProvider,
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
