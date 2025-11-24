import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/colorpalette.dart';
import 'package:iotproject/Function/data.dart';
import 'package:iotproject/Model/basket.dart';
import 'package:iotproject/main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Model/basket.dart';
import '../boxes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> with RouteAware {
  final AppData data = AppData();
  String deviceName = "";
  String status = "";
  String? statusBefore;
  Timer? pingTimer;

  @override
  void initState() {
    super.initState();
    startPing();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Daftarkan halaman ini ke routeObserver
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  void startPing() {
    pingTimer?.cancel();
    pingTimer = Timer.periodic(const Duration(seconds: 3), (_) => pingDevice());
  }

  void stopPing() {
    pingTimer?.cancel();
    pingTimer = null;
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    stopPing();
    super.dispose();
  }

  // 📌 Dipanggil kalau halaman ini ditinggalkan (misal ke /addPage)
  @override
  void didPushNext() {
    stopPing();
  }

  // 📌 Dipanggil kalau balik ke halaman ini lagi
  @override
  void didPopNext() {
    startPing();
  }

  Future<void> pingDevice() async {
    final url = Uri.parse('http://${data.esp32Ip}/ping');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newStatus = data['status'] ?? 'disconnected';
        final newDevice = data['device'] ?? '';

        // --- Hanya update UI kalau status berubah ---
        if (statusBefore == null || statusBefore != newStatus) {
          statusBefore = newStatus;
          setState(() {
            deviceName = newDevice;
            status = newStatus;
          });
        }
      } else {
        setDisconnected();
      }
    } catch (e) {
      setDisconnected();
    }
  }

  void setDisconnected() {
    if (statusBefore != 'disconnected') {
      statusBefore = 'disconnected';
      setState(() {
        deviceName = "";
        status = "disconnected";
      });
    }
  }

  // buat manggil api nama warna
  // Future<String?> getColorName(int r, int g, int b) async {
  //   try {
  //     final url = Uri.parse('https://www.thecolorapi.com/id?rgb=rgb($r,$g,$b)');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['name']['value'];
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.third,
        shadowColor: Colors.black.withOpacity(0.2),
        titleSpacing: 24,
        title: Text(
          "Hello, welcome to Sortify",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_rounded, color: Colors.black),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.005),
                Container(
                  height: screenHeight * 0.1,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                    color: AppColors.fourth,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/shirt.png', scale: 25),

                      SizedBox(width: screenWidth * 0.03),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // ⬅️ ini penting!
                        mainAxisAlignment: MainAxisAlignment
                            .center, // optional biar teks sejajar secara vertikal
                        children: [
                          Text(
                            statusBefore == "connected"
                                ? deviceName
                                : 'No sorter connected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            statusBefore == "connected"
                                ? 'Sorter is ready to use'
                                : 'Sorter not connected',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      Spacer(),

                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                Text(
                  'Saved Colors',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  'These are the colors you saved.',
                  style: TextStyle(fontSize: 13),
                ),

                SizedBox(height: screenHeight * 0.03),

                SizedBox(
                  width: screenWidth * 1,
                  height: screenHeight * 0.5,
                  child: Center(
                    child: ValueListenableBuilder<Box<Basket>>(
                      valueListenable: Boxes.getBasket().listenable(),
                      builder: (context, box, _) {
                        final baskets = box.values.toList().cast<Basket>();

                        if (baskets.isEmpty) {
                          return Center(
                            child: Text(
                              'No colors added',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: baskets.length,
                          itemBuilder: (context, index) {
                            final basket = baskets[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      basket.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    Text("Red A : ${basket.redAvgsA}"),
                                    Text("Green A : ${basket.greenAvgsA}"),
                                    Text("Blue A : ${basket.blueAvgsA}"),
                                    const SizedBox(height: 4),
                                    Text("Red B : ${basket.redAvgsB}"),
                                    Text("Green B : ${basket.greenAvgsB}"),
                                    Text("Blue B : ${basket.blueAvgsB}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Row(
                //   children: [
                //     Text('Color: ', style: TextStyle(fontSize: 13),),
                //     Row(
                //       children: List.generate(redAvgs.length, (i) {
                //         return FutureBuilder<String?>(
                //           future: getColorName(redAvgs[i], greenAvgs[i], blueAvgs[i]),
                //           builder: (context, snapshot) {
                //             String colorName = '...';
                //             if (snapshot.connectionState == ConnectionState.done) {
                //               if (snapshot.hasData) {
                //                 colorName = snapshot.data!;
                //               } else {
                //                 colorName = "Unknown";
                //               }
                //             }
                //             final isLast = i == redAvgs.length - 1;
                //             return Text(
                //               isLast ?
                //               colorName :
                //               '$colorName, ',
                //               style: const TextStyle(fontSize: 13),
                //             );
                //           },
                //         );
                //       }),
                //     ),
                //   ],
                // ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/addPage');

          if (result == true) {
            setState(() {});
          }
        },
        tooltip: 'Add',
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 40),
      ),
    );
  }
}
