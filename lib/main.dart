import 'package:flutter/material.dart';
//import 'package:nadiku/homescreen.dart';
import 'package:nadiku/login.dart';
//import 'package:nadiku/main_appbar.dart';
import 'package:nadiku/main_scaffold.dart';
import 'package:nadiku/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Flutter Bluetooth",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScaffold());
  }
}
