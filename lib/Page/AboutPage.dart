import 'package:flutter/material.dart';
import '../Function/colorpalette.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child:
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Sortify',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Build 1 (1.0.0)',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Sortify is an integrated application designed to work seamlessly with an automated clothing sorter. Its purpose is to help users easily distinguish between garments that are colorfast and those that are prone to fading. By combining smart detection technology with a user-friendly interface, Sortify ensures safer laundry sorting, reduces the risk of fabric damage, and simplifies the overall washing process.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: screenHeight * 0.03),

                Text(
                  'Meet Our Teams',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.third,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,   
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,              
                          border: Border.all(
                            color: Colors.black,               
                            width: 1,                          
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/Basket.png'),
                            fit: BoxFit.cover,                 
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Rayden Blezworth Arwan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Role: Mobile App Developer',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.second,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '2702266801',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.third,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/Basket.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Calvin Virya Yunardy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Role: Backend Developer',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.second,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '2702256271',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.third,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/Basket.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Jose Andreas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Role: IoT Engineer',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.second,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '2702233583',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

