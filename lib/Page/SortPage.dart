import 'dart:convert';
import 'dart:io';
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

  late List<int> a_red;
  late List<int> a_green;
  late List<int> a_blue;

  late List<int> b_red;
  late List<int> b_green;
  late List<int> b_blue;

  RawDatagramSocket? udpSocket;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil data warna dari arguments AddPage
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    a_red   = List<int>.from(args['a_red']);
    a_green = List<int>.from(args['a_green']);
    a_blue  = List<int>.from(args['a_blue']);

    b_red   = List<int>.from(args['b_red']);
    b_green = List<int>.from(args['b_green']);
    b_blue  = List<int>.from(args['b_blue']);

    startSorting();
    startListeningUDP();
  }

  // === Fungsi mulai sorting ===
  Future<void> startSorting() async {
    setState(() {
      isSorting = true;
      statusText = "Starting sorting process...";
    });

    // Buat map warna untuk basket A dan B sesuai ESP32
    final Map<String, dynamic> colorData = {
      "A": List.generate(a_red.length, (i) => {
        "red": a_red[i],
        "green": a_green[i],
        "blue": a_blue[i],
      }),
      "B": List.generate(b_red.length, (i) => {
        "red": b_red[i],
        "green": b_green[i],
        "blue": b_blue[i],
      }),
    };

    try {
      final response = await http.post(
        Uri.parse("http://${data.esp32Ip}/sort"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(colorData),
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

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // === UDP Listener ===
  void startListeningUDP() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4210);
    udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = udpSocket!.receive();
        if (dg != null) {
          String msg = utf8.decode(dg.data);
          print("UDP received: $msg");

          try {
            var dataJson = jsonDecode(msg);
            if (dataJson["action"] == "stop") {
              print("Received stop via UDP!");
              stopSorting();
            }
          } catch (e) {
            print("JSON parse error: $e");
          }
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
