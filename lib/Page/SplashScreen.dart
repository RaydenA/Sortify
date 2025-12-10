import 'package:iotproject/Page/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(
      const Duration(seconds: 5),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Homepage()),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf6c5c5), Color(0xFFdec1ee)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/Logo.png',
          ),
        ),
      ),
    );
  }
}