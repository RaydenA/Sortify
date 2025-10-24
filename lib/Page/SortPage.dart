import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/data.dart'; // ambil AppData
import 'package:lottie/lottie.dart';

class SortPage extends StatefulWidget {
  const SortPage({super.key});

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  final AppData data = AppData(); // ambil IP dari singleton AppData

  bool isSorting = false;
  String statusText = "Ready to sort";

  late List<int> redAvgs;
  late List<int> greenAvgs;
  late List<int> blueAvgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil data warna dari arguments AddPage
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    redAvgs = List<int>.from(args['redAvgs']);
    greenAvgs = List<int>.from(args['greenAvgs']);
    blueAvgs = List<int>.from(args['blueAvgs']);

    startSorting();
  }

  // === Fungsi mulai sorting ===
  Future<void> startSorting() async {
    setState(() {
      isSorting = true;
      statusText = "Starting sorting process...";
    });

    // buat list warna untuk dikirim ke ESP32
    List<Map<String, int>> colorList = [];
    for (int i = 0; i < redAvgs.length; i++) {
      colorList.add({
        "red": redAvgs[i],
        "green": greenAvgs[i],
        "blue": blueAvgs[i],
      });
    }

    try {
      final response = await http.post(
        Uri.parse("http://${data.esp32Ip}/sort"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(colorList),
      );

      if (response.statusCode == 200) {
        setState(() {
          statusText = "Sorting started. Detecting colors...";
        });
      } else {
        setState(() {
          statusText = "Failed to start sorting (HTTP ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        statusText = "Connection failed: $e";
      });
    }
  }

  // === Fungsi menghentikan sorting ===
  Future<void> stopSorting() async {
    setState(() {
      isSorting = false;
      statusText = "Stopping sorting...";
    });

    // kirim sinyal stop tanpa menunggu respons
    http.get(Uri.parse("http://${data.esp32Ip}/stop")).catchError((e) {
      print("Failed to send stop signal: $e");
    });

    // beri jeda 2 detik sebelum kembali ke AddPage
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                    'assets/animations/sort.json',
                    repeat: true,
                    animate: true,
                    height: 350,
                    width: 350
                ),
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.2,),
                ElevatedButton(
                  onPressed: stopSorting,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15)),
                  child: const Icon(
                    Icons.stop_rounded,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.1,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
