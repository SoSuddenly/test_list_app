import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'image_provider.dart';
import 'user_model.dart';
import 'user_detail_page.dart';
import 'internet_utils.dart';

class UserCard extends StatefulWidget {
  final UserModel user;

  UserCard({required this.user});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await InternetUtils
        .hasInternetConnection(); // Використання модулю InternetUtils
    setState(() {
      hasInternet = connectivityResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider =
        getImageProvider(widget.user.avatarUrl, hasInternet);

    return GestureDetector(
      onTap: () {
        Get.to(() => UserDetailPage(
              user: widget.user,
              hasInternet: hasInternet,
            ));
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${widget.user.firstName} ${widget.user.lastName}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(widget.user.email),
          ],
        ),
      ),
    );
  }
}
