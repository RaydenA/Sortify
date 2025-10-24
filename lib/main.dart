import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iotproject/Page/SortPage.dart';
import 'package:iotproject/Page/addPage.dart';
import 'package:iotproject/Page/HomePage.dart';
import 'package:iotproject/Page/detectPage.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFE6E8FD),
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(),
      routes: {
        '/homePage': (context) => Homepage(),
        '/addPage': (context) => AddPage(),
      },
    );
  }
}