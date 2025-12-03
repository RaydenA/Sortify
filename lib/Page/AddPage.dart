import 'package:flutter/material.dart';
import 'package:iotproject/Page/SortPage.dart';
import 'package:iotproject/Page/DetectPage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:iotproject/Function/data.dart';
import '../Function/colorpalette.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Model/basket.dart';
import '../boxes.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final AppData data = AppData();
  TextEditingController nameController = TextEditingController();
  bool isLoaded = false;
  // Simpan nilai RGB rata-rata & nama
  late String name = nameController.text;
  List<int> redAvgs = [];
  List<int> greenAvgs = [];
  List<int> blueAvgs = [];

  List<int> tempA_R = [];
  List<int> tempA_G = [];
  List<int> tempA_B = [];

  List<int> tempB_R = [];
  List<int> tempB_G = [];
  List<int> tempB_B = [];

  late var basket = Basket();

  void loadBasketToTemp(Basket basket) {
    // Temp A
    tempA_R = List.from(basket.redAvgsA);
    tempA_G = List.from(basket.greenAvgsA);
    tempA_B = List.from(basket.blueAvgsA);

    // Temp B
    tempB_R = List.from(basket.redAvgsB);
    tempB_G = List.from(basket.greenAvgsB);
    tempB_B = List.from(basket.blueAvgsB);

  }


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

    final basketPreset = ModalRoute.of(context)!.settings.arguments as Basket?;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (basketPreset != null && !isLoaded) {
      basket = basketPreset;
      nameController.text = basket.name;
      loadBasketToTemp(basketPreset);  // <-- temp di-load sekali
      isLoaded = true;                 // <-- tidak load lagi
    }

    return Scaffold(
      backgroundColor: AppColors.fourth,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.fourth,
        leadingWidth: 72,
        leading: IconButton(
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
                  MaterialPageRoute(builder: (_) => DetectPage()),
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
                        margin: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 10,
                        ),
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
                style: TextStyle(color: Colors.black, fontSize: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Click* basket to check color',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),

                    SizedBox(height: screenHeight * 0.005),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            DragTarget(
                              builder: (context, candidateData, rejectedData) {
                                return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        insetPadding: EdgeInsets.all(20), // Controls max width
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        title: Stack(
                                          children: [
                                            // Title text
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Non-colorfast clothes',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Close icon
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: InkWell(
                                                onTap: () => Navigator.pop(context),
                                                child: Icon(
                                                  Icons.cancel_rounded,
                                                  color: AppColors.second,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: SizedBox(
                                          width: screenWidth * 0.85,   // <--- Control dialog width here
                                          height: screenHeight * 0.55,  // <--- Control dialog height here
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: List.generate(tempA_R.length, (i) {
                                                return Card(
                                                  color: AppColors.first,
                                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black, width: 1),
                                                            color: Color.fromARGB(
                                                              255,
                                                              tempA_R[i],
                                                              tempA_G[i],
                                                              tempA_B[i],
                                                            ),
                                                          ),
                                                        ),

                                                        // === Button balikan ke grid avgs ===
                                                        IconButton(
                                                          onPressed: () {
                                                            // Kembalikan ke avgs grid
                                                            redAvgs.add(tempA_R[i]);
                                                            greenAvgs.add(tempA_G[i]);
                                                            blueAvgs.add(tempA_B[i]);

                                                            // Hapus dari tempB
                                                            tempA_R.removeAt(i);
                                                            tempA_G.removeAt(i);
                                                            tempA_B.removeAt(i);

                                                            setState(() {});
                                                            Navigator.pop(context);
                                                          },
                                                          icon: Icon(Icons.double_arrow_rounded, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),

                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                  },
                                  child: Image.asset(
                                    'assets/Basket.png',
                                    width: screenWidth * 0.475,
                                  ),
                                );
                              },
                              onWillAccept: (data) => true,
                              onAccept: (data) {
                                final item = data as Map<String, dynamic>;
                                final i = item['index'];

                                // Masukkan ke basket A
                                tempA_R.add(redAvgs[i]);
                                tempA_G.add(greenAvgs[i]);
                                tempA_B.add(blueAvgs[i]);

                                // Hapus dari grid avgs
                                redAvgs.removeAt(i);
                                greenAvgs.removeAt(i);
                                blueAvgs.removeAt(i);

                                setState(() {});
                              },
                            ),
                            Text(
                              'Non-colorfast clothes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: screenWidth * 0.01),

                        Column(
                          children: [
                            DragTarget(
                              builder: (context, candidateData, rejectedData) {
                                return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        insetPadding: EdgeInsets.all(20), // Controls max width
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        title: Stack(
                                          children: [
                                            // Title text
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Colorfast clothes',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            // Close icon
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: InkWell(
                                                onTap: () => Navigator.pop(context),
                                                child: Icon(
                                                  Icons.cancel_rounded,
                                                  color: AppColors.second,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: SizedBox(
                                          width: screenWidth * 0.85,   // <--- Control dialog width here
                                          height: screenHeight * 0.55,  // <--- Control dialog height here
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: List.generate(tempB_R.length, (i) {
                                                return Card(
                                                  color: AppColors.first,
                                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: 35,
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black, width: 1),
                                                            color: Color.fromARGB(
                                                              255,
                                                              tempB_R[i],
                                                              tempB_G[i],
                                                              tempB_B[i],
                                                            ),
                                                          ),
                                                        ),

                                                        // === Button balikan ke grid avgs ===
                                                        IconButton(
                                                          onPressed: () {
                                                            // Kembalikan ke avgs grid
                                                            redAvgs.add(tempB_R[i]);
                                                            greenAvgs.add(tempB_G[i]);
                                                            blueAvgs.add(tempB_B[i]);

                                                            // Hapus dari tempB
                                                            tempB_R.removeAt(i);
                                                            tempB_G.removeAt(i);
                                                            tempB_B.removeAt(i);

                                                            setState(() {});
                                                            Navigator.pop(context);
                                                          },
                                                          icon: Icon(Icons.double_arrow_rounded, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),

                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                  },
                                  child: Image.asset(
                                    'assets/Basket.png',
                                    width: screenWidth * 0.475,
                                  ),
                                );
                              },
                              onWillAccept: (data) => true,
                              onAccept: (data) {
                                final item = data as Map<String, dynamic>;
                                final i = item['index'];

                                // Masukkan ke basket A
                                tempB_R.add(redAvgs[i]);
                                tempB_G.add(greenAvgs[i]);
                                tempB_B.add(blueAvgs[i]);

                                // Hapus dari grid avgs
                                redAvgs.removeAt(i);
                                greenAvgs.removeAt(i);
                                blueAvgs.removeAt(i);

                                setState(() {});
                              },
                            ),
                            Text(
                              'Colorfast clothes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height *
                            0.55, // misal maksimal 60% tinggi layar
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.third,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                            bottom: Radius.circular(0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.015),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Picked Colors',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  'Drag the color to your basket!',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            (redAvgs.isEmpty &&
                                    greenAvgs.isEmpty &&
                                    blueAvgs.isEmpty)
                                ? SizedBox(
                                    width: screenWidth * 1,
                                    height: screenHeight * 0.35,

                                    child: Center(
                                      child: Text(
                                        'No colors added',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
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
                                      final color = Color.fromARGB(
                                        255, r, g, b,
                                      );

                                      return Draggable(
                                        data: {
                                          'r': r,
                                          'g': g,
                                          'b': b,
                                          'index': index,
                                        },
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              18.0,
                                            ),
                                            child: Container(

                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/shirt.png',
                                                  scale: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(4, 4),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                                        padding:
                                                            const EdgeInsets.all(
                                                              18.0,
                                                            ),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: color
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  80,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Image.asset(
                                                          'assets/shirt.png',
                                                          scale: 13,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              redAvgs.removeAt(
                                                                index,
                                                              );
                                                              greenAvgs
                                                                  .removeAt(
                                                                    index,
                                                                  );
                                                              blueAvgs.removeAt(
                                                                index,
                                                              );
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .cancel_rounded,
                                                            color: AppColors
                                                                .second,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                    SizedBox(width: 24),
                    TextButton(
                      onPressed: () async {
                        if (redAvgs.isEmpty &&
                            greenAvgs.isEmpty &&
                            blueAvgs.isEmpty) {
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
                              margin: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 10,
                              ),
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
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
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
                                Text(
                                  'Save Color Set',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                              ],
                            ),

                            content: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: screenWidth * 0.7,
                                maxWidth: screenWidth * 0.7,
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
                                onPressed: () {
                                  final box = Boxes.getBasket();

                                  if (basketPreset != null) {
                                    // Update basket existing
                                    basketPreset.name = nameController.text;

                                    basketPreset.redAvgsA = List.from(tempA_R);
                                    basketPreset.greenAvgsA = List.from(tempA_G);
                                    basketPreset.blueAvgsA = List.from(tempA_B);

                                    basketPreset.redAvgsB = List.from(tempB_R);
                                    basketPreset.greenAvgsB = List.from(tempB_G);
                                    basketPreset.blueAvgsB = List.from(tempB_B);

                                    basketPreset.save();
                                  } else {
                                    // New basket
                                    basket.name = nameController.text;

                                    basket.redAvgsA = List.from(tempA_R);
                                    basket.greenAvgsA = List.from(tempA_G);
                                    basket.blueAvgsA = List.from(tempA_B);

                                    basket.redAvgsB = List.from(tempB_R);
                                    basket.greenAvgsB = List.from(tempB_G);
                                    basket.blueAvgsB = List.from(tempB_B);

                                    box.add(basket);
                                  }

                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },

                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                        if (tempA_R.isEmpty || tempB_R.isEmpty) {
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
                              margin: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 10,
                              ),
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
                                'a_red': tempA_R,
                                'a_green': tempA_G,
                                'a_blue': tempA_B,

                                'b_red': tempB_R,
                                'b_green': tempB_G,
                                'b_blue': tempB_B,
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Sort",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
