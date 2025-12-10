import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/data.dart';
import 'package:lottie/lottie.dart';

class SortPage extends StatefulWidget {
  const SortPage({super.key});

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  final AppData data = AppData();

  bool isSorting = false;
  String statusText = "Ready to sort";

  // ganti dari int ke List<int> supaya bisa kirim semua warna
  List<int> redA = [];
  List<int> greenA = [];
  List<int> blueA = [];
  List<int> redB = [];
  List<int> greenB = [];
  List<int> blueB = [];

  RawDatagramSocket? udpSocket;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Ambil list warna A
    redA = List<int>.from(args['a_red']);
    greenA = List<int>.from(args['a_green']);
    blueA = List<int>.from(args['a_blue']);

    // Ambil list warna B
    redB = List<int>.from(args['b_red']);
    greenB = List<int>.from(args['b_green']);
    blueB = List<int>.from(args['b_blue']);

    if (!isSorting) startSorting();

    startListeningUDP();
  }

  Future<void> startSorting() async {
    setState(() {
      isSorting = true;
      statusText = "Starting sorting...";
    });

    // kirim semua list warna ke ESP32
    final colorData = {
      "red_a": redA,
      "green_a": greenA,
      "blue_a": blueA,
      "red_b": redB,
      "green_b": greenB,
      "blue_b": blueB,
    };

    try {
      final response = await http.post(
        Uri.parse("http://${data.esp32Ip}/sort"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(colorData),
      );

      if (response.statusCode == 200) {
        setState(() => statusText = "Sorting started...");
      } else {
        setState(() => statusText = "Failed (HTTP ${response.statusCode})");
      }
    } catch (e) {
      setState(() => statusText = "Connection failed: $e");
    }
  }

  Future<void> stopSorting() async {
    setState(() {
      isSorting = false;
      statusText = "Stopping sorting...";
    });

    http.get(Uri.parse("http://${data.esp32Ip}/stop")).catchError((e) {
      print("Failed to send stop signal: $e");
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> stopSortingFull() async {
    setState(() {
      isSorting = false;
      statusText = "Stopping sorting...";
    });

    http.get(Uri.parse("http://${data.esp32Ip}/stop")).catchError((e) {
      print("Failed to send stop signal: $e");
    });

    udpSocket?.close();
    udpSocket = null;

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) Navigator.pushReplacementNamed(context, '/validation');
  }

  void startListeningUDP() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4210);
    udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = udpSocket!.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data);
          print("UDP received: $msg");

          try {
            final json = jsonDecode(msg);
            if (json["action"] == "stop") stopSortingFull();
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    udpSocket?.close();
    super.dispose();
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
                  width: 350,
                ),
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.2,
                ),
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
                SizedBox(
                  height: screenHeight * 0.1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
