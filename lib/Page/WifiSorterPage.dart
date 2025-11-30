import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../Function/colorpalette.dart';
import 'package:iotproject/Function/data.dart';
import 'package:http/http.dart' as http;

class WifiSorterPage extends StatefulWidget {
  const WifiSorterPage({super.key});

  @override
  State<WifiSorterPage> createState() => _WifiSorterPageState();
}

class _WifiSorterPageState extends State<WifiSorterPage> {
  final AppData data = AppData();

  TextEditingController ssidController = TextEditingController();
  TextEditingController passController = TextEditingController();

  List<Map<String, String>> espList = [];

  RawDatagramSocket? socketListener;

  @override
  void initState() {
    super.initState();
    startUdpListener();
  }

  @override
  void dispose() {
    socketListener?.close();
    super.dispose();
  }

  // ───────────────────────────────
  // UDP LISTENER
  // ───────────────────────────────
  void startUdpListener() async {
    print("Starting UDP listener on port 4210...");

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 4210).then((socket) {
      socketListener = socket;
      socket.broadcastEnabled = true;

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram == null) return;

          final msg = utf8.decode(datagram.data);
          final senderIp = datagram.address.address;

          print("UDP Raw Message: $msg from $senderIp");

          try {
            // Parse JSON dari ESP32
            final Map<String, dynamic> parsed = jsonDecode(msg);
            final name = parsed['device'] as String;
            final ip = parsed['ip'] as String;

            if (!espList.any((e) => e['ip'] == ip)) {
              setState(() {
                espList.add({"name": name, "ip": ip});
              });
            }
          } catch (e) {
            print("UDP message is not valid JSON: $msg");
          }
        }
      });
    });
  }

  // ───────────────────────────────
  // SEND WIFI TO ESP32
  // ───────────────────────────────
  Future<void> sendWifiToESP() async {
    final ssid = ssidController.text.trim();
    final pass = passController.text.trim();

    if (data.esp32Ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an ESP32 first")),
      );
      return;
    }

    final url = Uri.parse("http://${data.esp32Ip}/wifi");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ssid": ssid, "password": pass}),
      );

      print("Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("WiFi sent to ESP32")),
      );
    } catch (e) {
      print("Error sending WiFi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send WiFi")),
      );
    }
  }

  // ───────────────────────────────
  // SHOW MODAL LIST ESP32
  // ───────────────────────────────
  void showEspModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Available ESP32 Devices",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: espList.isEmpty
                    ? Center(
                  child: Text(
                    "Searching for ESP32...",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: espList.length,
                  itemBuilder: (context, index) {
                    final device = espList[index];

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.memory),
                        title: Text(device['name']!),
                        subtitle: Text(device['ip']!),
                        onTap: () {
                          setState(() {
                            data.esp32Ip = device['ip']!;
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Selected ESP32: ${device['ip']}",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────────────
  // UI
  // ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.fourth,
      appBar: AppBar(
        backgroundColor: AppColors.fourth,
        toolbarHeight: 60,
        leadingWidth: 72,
        leading: IconButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.005),
              // Card Select ESP32
              Container(
                height: screenHeight * 0.1,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.fourth,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset('assets/shirt.png', scale: 25),
                    SizedBox(width: screenWidth * 0.03),
                    Text(
                      data.esp32Ip.isEmpty
                          ? "Select ESP32"
                          : "Selected: ${data.esp32Ip}",
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: showEspModal,
                      icon: Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  ],
                ),
              ),
              // Input WiFi
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    TextField(
                      controller: ssidController,
                      decoration: InputDecoration(
                        labelText: "SSID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    ElevatedButton(
                      onPressed: sendWifiToESP,
                      child: Text("Connect ESP32 to WiFi"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
