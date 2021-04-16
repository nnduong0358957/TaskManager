import 'package:flutter/material.dart';
import 'package:todo_list_app/screens/login_page/login.dart';
import 'package:todo_list_app/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: kPrimaryColor,
      ),
      home: MyLoginPage(),
    );
  }
}
