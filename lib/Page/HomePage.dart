import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.2),
        title: Text("Hello, welcome to Sortify", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.info_rounded, color: Colors.black,)
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/shirt.png', scale: 25,),

                      SizedBox(width: screenWidth * 0.03,),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ ini penting!
                        mainAxisAlignment: MainAxisAlignment.center,   // optional biar teks sejajar secara vertikal
                        children: [
                          Text(
                            'Connect to sorter',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005,),
                          Text(
                            'Sorter not connected.',
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

                Text('Your Colors', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

                SizedBox(height: screenHeight * 0.015),
              ],
            ),
          )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPage');
        },
        tooltip: 'Add',
        backgroundColor: Colors.grey[200],
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
