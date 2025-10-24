import 'package:flutter/material.dart';
import 'package:iotproject/Page/SortPage.dart';
import 'package:iotproject/Page/DetectPage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:iotproject/Function/data.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final AppData data = AppData();
  // Simpan nilai RGB rata-rata
  List<int> redAvgs = [];
  List<int> greenAvgs = [];
  List<int> blueAvgs = [];

  static const int maxColors = 5; // batas maksimal warna

  // Fungsi cek kemiripan warna
  bool isColorSimilar(Color newColor) {
    for (int i = 0; i < redAvgs.length; i++) {
      int rDiff = (redAvgs[i] - newColor.red).abs();
      int gDiff = (greenAvgs[i] - newColor.green).abs();
      int bDiff = (blueAvgs[i] - newColor.blue).abs();

      if (rDiff <= 5 && gDiff <= 5 && bDiff <= 5) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xFF509AC2),
        shadowColor: Colors.black.withOpacity(0.2),
        leading:
        IconButton(
          color: const Color(0xFFFFFFFF),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (redAvgs.length >= maxColors) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Maximum colors reached!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                );
                return;
              }

              // Buka halaman deteksi dan tunggu hasilnya
              Color? detectedColor = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetectPage(),
                ),
              );

              // Kalau dapat warna, validasi kemiripan
              if (detectedColor != null) {
                if (isColorSimilar(detectedColor)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "This color already exist!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                  );
                  return; // jangan tambah warna
                }

                // Kalau tidak mirip, simpan ke list
                setState(() {
                  redAvgs.add(detectedColor.red);
                  greenAvgs.add(detectedColor.green);
                  blueAvgs.add(detectedColor.blue);
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],

      ),
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.025),
                    // 🟩 Tampilan container warna
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(4, 4),
                          )
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: screenHeight * 0.2,
                          color: Colors.grey[200],
                          child: redAvgs.isEmpty
                              ? const Center(
                              child: Icon(
                                Icons.color_lens,
                                size: 100,
                                color: Colors.white,
                              ))
                              : Row(
                            children: List.generate(redAvgs.length, (index) {
                              final r = redAvgs[index];
                              final g = greenAvgs[index];
                              final b = blueAvgs[index];
                              final color = Color.fromARGB(255, r, g, b);

                              return Expanded(
                                child: Container(
                                  height: screenHeight * 0.2,
                                  decoration: BoxDecoration(
                                    color: color,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),
                    // GridView tampilan warna dan gauge
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: redAvgs.length,
                      itemBuilder: (context, index) {
                        final r = redAvgs[index];
                        final g = greenAvgs[index];
                        final b = blueAvgs[index];
                        final color = Color.fromARGB(255, r, g, b);

                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(4, 4),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: SfRadialGauge(
                                    axes: <RadialAxis>[
                                      RadialAxis(
                                        radiusFactor: 0.9,
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: r / 255 * 100,
                                            cornerStyle: CornerStyle.bothFlat,
                                            color: Colors.red,
                                          )
                                        ],
                                        interval: 5,
                                        startAngle: 90,
                                        endAngle: 90,
                                        showTicks: false,
                                        showLabels: false,
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                            positionFactor: 0.065,
                                            widget:
                                            Icon(
                                              Icons.color_lens_rounded,
                                              color: (r >= 250 && g >= 250 && b >= 250)
                                              ? Colors.grey[400]
                                              : color,
                                              size: 100,
                                            )
                                            // Container(
                                            //   margin: EdgeInsets.all(60),
                                            //   decoration: BoxDecoration(
                                            //     color: color,
                                            //     borderRadius: BorderRadius.circular(10),
                                            //   ),
                                            // ),
                                          )
                                        ],
                                      ),
                                      RadialAxis(
                                        radiusFactor: 0.75,
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: g / 255 * 100,
                                            cornerStyle: CornerStyle.bothFlat,
                                            color: Colors.green,
                                          )
                                        ],
                                        interval: 5,
                                        startAngle: 90,
                                        endAngle: 90,
                                        showTicks: false,
                                        showLabels: false,
                                      ),
                                      RadialAxis(
                                        radiusFactor: 0.6,
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: b / 255 * 100,
                                            cornerStyle: CornerStyle.bothFlat,
                                            color: Colors.blue,
                                          )
                                        ],
                                        interval: 5,
                                        startAngle: 90,
                                        endAngle: 90,
                                        showTicks: false,
                                        showLabels: false,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Color(0xFFE7F2F8),
                                  child: Center(
                                    child: Text(
                                      'R:$r  G:$g  B:$b',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.09),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth * 1,
              height: 60,
              color: Color(0xFF509AC2),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.03),
                    child: TextButton(
                      onPressed: () {
                        if (redAvgs.isEmpty && greenAvgs.isEmpty && blueAvgs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "All colors cleared!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            ),
                          );
                        } else {
                          setState(() {
                            redAvgs.clear();
                            greenAvgs.clear();
                            blueAvgs.clear();
                          });
                        }
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    )
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.01),
                      child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ))),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.03),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (redAvgs.length < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Add more than 1 color!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SortPage(),
                            settings: RouteSettings(
                              arguments: {
                                'redAvgs': redAvgs,
                                'greenAvgs': greenAvgs,
                                'blueAvgs': blueAvgs,
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Sort",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
