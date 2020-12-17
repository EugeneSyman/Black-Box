import 'package:blackbox/UI/Elements/navigation.dart';
import 'package:blackbox/UI/Pages/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.indigoAccent[700]),
      home: LoginPage(),
    );
  }
}
