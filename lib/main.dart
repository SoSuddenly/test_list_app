import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_list_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme:
          ThemeData(primaryColor: Colors.teal), // Зміна теми на теаловий колір
      title: 'User List App',
      home: UserListPage(),
    );
  }
}
