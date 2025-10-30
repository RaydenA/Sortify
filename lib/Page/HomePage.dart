import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/Function/colorpalette.dart';
import 'package:iotproject/Function/data.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final AppData data = AppData();

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
        backgroundColor: AppColors.third,
        shadowColor: Colors.black.withOpacity(0.2),
        titleSpacing: 24,
        title: Text("Hello, welcome to Sortify", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              onPressed: (){},
              icon: Icon(Icons.info_rounded, color: Colors.black,)
            ),
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.005,),
                Container(
                  height: screenHeight * 0.1,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      )
                    ],
                    color: AppColors.fourth,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/shirt.png', scale: 25,),

                      SizedBox(width: screenWidth * 0.03,),


                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ ini penting!
                        mainAxisAlignment: MainAxisAlignment.center,   // optional biar teks sejajar secara vertikal
                        children:
                        [
                          Text(
                            'No sorter connected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005,),
                          Text(
                            'Sorter not connected',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      Spacer(),

                      IconButton(
                          onPressed: (){

                          },
                          icon: Icon(Icons.arrow_forward_ios_rounded)
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03,),

                Text('Saved Colors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                SizedBox(height: screenHeight * 0.005,),
                Text('These are the colors you saved.', style: TextStyle(fontSize: 13,),),

                SizedBox(height: screenHeight * 0.03),

                SizedBox(
                    width: screenWidth * 1,
                    height: screenHeight * 0.5,
                    child: Center(
                        child: Text('No colors added', style: TextStyle(color: Colors.white),)
                    )
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
          )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/addPage');

          if (result == true) {
            setState(() {

            });
          }
        },
        tooltip: 'Add',
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),

    );
  }
}
