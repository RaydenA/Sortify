import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/colorpalette.dart';
import 'package:iotproject/Function/data.dart';
import 'package:iotproject/Model/basket.dart';
import 'package:iotproject/consts.dart';
import 'package:iotproject/main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/weather.dart';
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

  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    startPing();
    _wf.currentWeatherByCityName("Jakarta").then((w) {
      setState(() {
        _weather = w;
      });
    });
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
    Hive.close();
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

  String laundryRecommendation(String? weatherMain) {
    if (weatherMain == null) {
      return "Today's weather cannot be determined for laundry.";
    }

    if (weatherMain == "Clear") {
      return "Today's weather is clear and perfect for doing laundry.";
    }
    else if (weatherMain == "Clouds") {
      return "Today's weather is cloudy but still suitable for laundry.";
    }
    else if (weatherMain == "Rain") {
      return "Today's weather is rainy and not suitable for laundry.";
    }
    else if (weatherMain == "Drizzle") {
      return "Today's weather is drizzly and not recommended for laundry.";
    }
    else if (weatherMain == "Thunderstorm") {
      return "Today's weather has thunderstorms and is unsafe for laundry.";
    }
    else if (weatherMain == "Mist") {
      return "Today's weather is misty and not ideal for laundry.";
    }
    else if (weatherMain == "Haze") {
      return "Today's weather is hazy and not good for laundry.";
    }
    else if (weatherMain == "Fog") {
      return "Today's weather is foggy and not suitable for laundry.";
    }
    else if (weatherMain == "Dust") {
      return "Today's weather is dusty and not suitable for laundry.";
    }
    else if (weatherMain == "Smoke") {
      return "Today's weather is smoky and not suitable for laundry.";
    }
    else {
      return "Today's weather conditions are not suitable for laundry.";
    }
  }


  // buat manggil api nama warna
  Future<String?> getColorName(int r, int g, int b) async {
    try {
      final url = Uri.parse('https://www.thecolorapi.com/id?rgb=rgb($r,$g,$b)');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name']['value'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.first,
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
              onPressed: () {
                Navigator.pushNamed(context, '/aboutPage');
              },
              icon: Icon(Icons.info_rounded, color: Colors.black),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.005,),

                  Column(
                    children: [
                      _weather != null
                          ? Container(
                        padding: const EdgeInsets.fromLTRB(24, 0, 39, 0),
                        child: Row(
                          children: [
                            Image.network(
                              "https://openweathermap.org/img/wn/${_weather!.weatherIcon}@2x.png",
                              width: 50,
                              height: 50,
                            ),

                            const SizedBox(width: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _weather!.areaName ?? "",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _weather!.weatherDescription ?? "",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),

                            const Spacer(),

                            Text(
                              "${_weather!.temperature?.celsius?.round()}°C",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                          : const Center(
                        child: CircularProgressIndicator(),
                      ),

                      SizedBox(height: screenHeight * 0.01,),

                      Text(
                        laundryRecommendation(_weather?.weatherMain),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.fourth,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.08,),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical( top: Radius.circular(15), bottom: Radius.circular(0)),
                      color: Colors.white,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.7, // ⬅️ minimum ke bawah
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.08),
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

                          ValueListenableBuilder<Box<Basket>>(
                            valueListenable: Boxes.getBasket().listenable(),
                            builder: (context, box, _) {
                              final baskets = box.values.toList().cast<Basket>();

                              if (baskets.isEmpty) {
                                return SizedBox(
                                  width: screenWidth * 1,
                                  height: screenHeight * 0.45,
                                  child: Center(
                                    child: Text(
                                      'No colors added',
                                      style: TextStyle(color: AppColors.fourth),
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: baskets.length,
                                itemBuilder: (context, index) {
                                  final basket = baskets[index];

                                  return InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/addPage',
                                        arguments: baskets[index], // index item hive
                                      );
                                    },
                                    child: Card(
                                      elevation: 3,
                                      margin: EdgeInsets.only(bottom: 20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  basket.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    box.deleteAt(index);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 12),
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("Non-colorfast: "),
                                                    Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: List.generate(
                                                        basket.redAvgsA.length,
                                                            (i) {
                                                          return Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color: Colors.black,  // border color
                                                                width: 1,             // border width
                                                              ),
                                                              color: Color.fromARGB(
                                                                255,
                                                                basket.redAvgsA[i],
                                                                basket.greenAvgsA[i],
                                                                basket.blueAvgsA[i],

                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Text("Colorfast: "),
                                                    Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: List.generate(
                                                        basket.redAvgsB.length,
                                                            (i) {
                                                          return Container(
                                                            width: 30,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color: Colors.black,  // border color
                                                                width: 1,             // border width
                                                              ),
                                                              color: Color.fromARGB(
                                                                255,
                                                                basket.redAvgsB[i],
                                                                basket.greenAvgsB[i],
                                                                basket.blueAvgsB[i],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  SizedBox(height: screenHeight * 0.12),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                    child: Container(
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
                        color: AppColors.second,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/shirt.png', scale: 8),

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
                                    color: AppColors.first
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                statusBefore == "connected"
                                    ? 'Sorter is ready to use'
                                    : 'Sorter not connected',
                                style: TextStyle(fontSize: 13, color: AppColors.first),
                              ),
                            ],
                          ),

                          Spacer(),

                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/sorterPage');
                            },
                            icon: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.first,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),



            ],
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
