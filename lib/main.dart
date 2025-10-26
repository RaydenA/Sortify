import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iotproject/Page/addPage.dart';
import 'package:iotproject/Page/HomePage.dart';
import 'Function/data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  );

  await Hive.initFlutter();
  
  Hive.registerAdapter(ColorSetAdapter());
  await Hive.openBox<ColorSet>('colorSets');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
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