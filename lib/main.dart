import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iotproject/Model/basket.dart';
import 'package:iotproject/Page/addPage.dart';
import 'package:iotproject/Page/HomePage.dart';
import 'package:iotproject/Page/AboutPage.dart';
import 'package:iotproject/Page/WifiSorterPage.dart';
import 'Function/colorpalette.dart';
import 'Function/data.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  Hive.registerAdapter(BasketAdapter());

  await Hive.openBox<Basket>('basket');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: AppColors.third),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: Homepage(),
      routes: {
        '/homePage': (context) => Homepage(),
        '/addPage': (context) => AddPage(),
        '/aboutPage': (context) => AboutPage(),
        '/sorterPage': (context) => WifiSorterPage(),
      },
    );
  }
}
