import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_list_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.teal),
      ),
      title: 'User List App',
      home: UserListPage(),
    );
  }
}
