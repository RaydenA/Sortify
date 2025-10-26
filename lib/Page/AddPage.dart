import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final box = Hive.box<ColorSet>('colorSets');

  TextEditingController nameController = TextEditingController();
  // Simpan nilai RGB rata-rata & nama
  String name = "";
  List<int> redAvgs = [];
  List<int> greenAvgs = [];
  List<int> blueAvgs = [];

  static const int maxColors = 5; // batas maksimal warna

  // Buat objek baru dari data yang sudah kamu kumpulkan
  late final colorSet = ColorSet()
    ..name = name
    ..redAvgs = List.from(redAvgs)
    ..greenAvgs = List.from(greenAvgs)
    ..blueAvgs = List.from(blueAvgs);

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
        backgroundColor: Colors.white,
        leading:
        IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context, true);
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
                color: Colors.black,
                fontSize: 16
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
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.005),
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

                      SizedBox(height: screenHeight * 0.03),

                      Row(
                        children: [
                          Text('Added Colors ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          Text(name.isNotEmpty ? "#$name" : "", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      (redAvgs.isEmpty && greenAvgs.isEmpty && blueAvgs.isEmpty)
                      ? SizedBox(
                        width: screenWidth * 1,
                        height: screenHeight * 0.45,

                        child: Center(
                            child: Text('No colors added', style: TextStyle(color: Colors.grey[400]),)
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
                                              color: (r <= 10 && g <= 10 && b <= 10)
                                                  ? Colors.black54  // if RGB = 0
                                                  : color,
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
                                            icon: Icon(Icons.cancel_rounded, color: Colors.grey[400],)
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.grey[300],
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
            ),
            // Bottom bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: screenWidth * 1,
                height: 60,
                color: Colors.grey[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 12,),
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
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),

                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Save Color Set', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),),
                                SizedBox(height: screenHeight*0.01)
                              ],
                            ),

                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: screenWidth * 0.7,
                                maxWidth: screenWidth * 0.7
                              ),

                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: "e.g. Color1",
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),

                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {

                                  bool nameExists = false;

                                  for (int i = 0; i < box.length; i++) {
                                    final colorSet = box.getAt(i);
                                    if (colorSet?.name == nameController.text.trim()) {
                                      nameExists = true;
                                      break;
                                    }
                                  }

                                  if (nameController.text.trim().isEmpty) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Name must be filled!",
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
                                  }else if (redAvgs.length < 2) {
                                    Navigator.pop(context);
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
                                  }else if (nameExists) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Name already exist!",
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

                                  setState(() {
                                    name = nameController.text.trim();
                                  });

                                  await box.add(colorSet);

                                  Navigator.pop(context);
                                },
                                child: Text('Save', style: TextStyle(fontSize: 13, color: Colors.white),)
                              ),
                              TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Cancel', style: TextStyle(fontSize: 13, color: Colors.red),)),
                            ],

                          ),
                        );
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
                    SizedBox(width: 12,),
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
