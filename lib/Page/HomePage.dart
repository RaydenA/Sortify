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
        backgroundColor: Color(0xFF509AC2),
        shadowColor: Colors.black.withOpacity(0.2),
        title: Text("Sortify", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02,),
                  Container(
                    color: Colors.white,
                    height: screenHeight * 0.2,
                  )
                ],
              ),
            ),
          )
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPage');
        },
        tooltip: 'Add',
        backgroundColor: Color(0xFF509AC2),
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),

    );
  }
}
