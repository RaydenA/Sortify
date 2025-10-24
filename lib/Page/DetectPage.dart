import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/data.dart'; // ambil AppData
import 'package:lottie/lottie.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({super.key});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final AppData data = AppData(); // untuk ambil IP saja

  int red = 0, green = 0, blue = 0; // live display
  List<int> redSamples = [];
  List<int> greenSamples = [];
  List<int> blueSamples = [];

  Timer? timer;
  int fetchCount = 0;
  final int totalFetches = 5;
  final int intervalSeconds = 1;
  bool isCancelled = false;

  @override
  void initState() {
    super.initState();
    startDetection();
  }

  void startDetection() {
    timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      if (isCancelled || fetchCount >= totalFetches) {
        timer?.cancel();

        if (!isCancelled && redSamples.isNotEmpty) {
          int avgRed = (redSamples.reduce((a, b) => a + b) / redSamples.length).round();
          int avgGreen = (greenSamples.reduce((a, b) => a + b) / greenSamples.length).round();
          int avgBlue = (blueSamples.reduce((a, b) => a + b) / blueSamples.length).round();

          // ✅ Kirim hasil ke AddPage (tanpa menyentuh AppData)
          Navigator.pop(context, Color.fromARGB(255, avgRed, avgGreen, avgBlue));
        } else {
          Navigator.pop(context, null);
        }
        return;
      }

      try {
        final response = await http.get(Uri.parse('http://${data.esp32Ip}/rgb'));
        if (response.statusCode == 200) {
          final d = jsonDecode(response.body);
          redSamples.add(d['red']);
          greenSamples.add(d['green']);
          blueSamples.add(d['blue']);
          fetchCount++;

          setState(() {
            red = d['red'];
            green = d['green'];
            blue = d['blue'];
          });
        }
      } catch (e) {
        print('Error fetching RGB: $e');
      }
    });
  }


  void cancelDetection() {
    setState(() {
      isCancelled = true;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final colorDisplay = Color.fromARGB(255, red, green, blue);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: screenHeight *0.25,),
                Lottie.network(
                  'https://lottie.host/3237117f-45b5-4dd2-b584-ad5e837fbbcb/gHVr5f6gMY.json',
                  height: 200,
                  width: 200
                ),
                SizedBox(height: screenHeight *0.08,),
                Text(
                  isCancelled ? 'Detection cancelled' : 'Detecting color...',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // const SizedBox(height: 16),
                // Text(
                //   'R: $red  |  G: $green  |  B: $blue',
                //   style: const TextStyle(fontSize: 18),
                // ),
                // const SizedBox(height: 16),
                // Container(
                //   width: 150,
                //   height: 150,
                //   decoration: BoxDecoration(
                //     color: colorDisplay,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                // ),
                SizedBox(height: screenHeight *0.2,),
                ElevatedButton(
                  onPressed: cancelDetection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Icon(Icons.stop_rounded, size: 35, color: Colors.white),
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
