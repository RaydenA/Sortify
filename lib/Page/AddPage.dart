import 'package:flutter/material.dart';
import 'package:iotproject/Page/SortPage.dart';
import 'package:iotproject/Page/DetectPage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:iotproject/Function/data.dart';
import '../Function/colorpalette.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final AppData data = AppData();
  TextEditingController nameController = TextEditingController();
  // Simpan nilai RGB rata-rata & nama
  String name = "";
  List<int> redAvgs = [10, 255];
  List<int> greenAvgs = [10, 30];
  List<int> blueAvgs = [10, 50];

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
      backgroundColor: AppColors.fourth,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.fourth,
        leadingWidth: 72,
        leading:
        IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: TextButton(
              onPressed: () async {

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
                  color: Colors.black,
                  fontSize: 16
                ),
              ),
            ),
          ),
        ],

      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [

                      ],
                    ),

                    SizedBox(height: screenHeight * 0.005),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.6, // misal maksimal 60% tinggi layar
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.third,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),

                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.015),

                            Row(
                              children: [
                                Text('Picked Colors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                                Text(name.isNotEmpty ? "#$name" : "", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.015),

                            (redAvgs.isEmpty && greenAvgs.isEmpty && blueAvgs.isEmpty)
                                ? SizedBox(
                                width: screenWidth * 1,
                                height: screenHeight * 0.45,

                                child: Center(
                                    child: Text('No colors added', style: TextStyle(color: Colors.white),)
                                )
                            )
                                : GridView.builder(
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
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(18.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: color.withOpacity(0.7),
                                                      borderRadius: BorderRadius.circular(80),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                    'assets/shirt.png',
                                                    scale: 13,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: IconButton(
                                                      onPressed: (){
                                                        setState(() {
                                                          redAvgs.removeAt(index);
                                                          greenAvgs.removeAt(index);
                                                          blueAvgs.removeAt(index);
                                                        });
                                                      },
                                                      icon: Icon(Icons.cancel_rounded, color: AppColors.second,)
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: AppColors.first,
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
                            SizedBox(height: screenHeight * 0.1),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            // Bottom bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth * 1,
                height: 60,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 24,),
                    TextButton(
                      onPressed: () async {
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
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    ),

                    TextButton(
                      onPressed: () {

                      },

                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    ),

                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      )
                    ),
                    SizedBox(width: 24,),
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
