import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Validation extends StatefulWidget {
  const Validation({super.key});

  @override
  State<Validation> createState() => _ValidationState();
}

class _ValidationState extends State<Validation> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Stack(
        children: [
          // This is to fill the entire stack
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
              )
                  .animate()
                  .slideY(
                begin: -0.8,   // mulai dari atas
                end: 0.0,      // 0.0 = tepat di tengah
                duration: 1.seconds,
                curve: Curves.easeOut, // jatuh natural
              )
                  .then()
                  .scaleXY(
                end: 20,
                duration: 2.seconds,
                curve: Curves.easeInOut,
              )
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.verified_rounded,
              size: 150,
              color: Colors.white,
            ),
          )
              .animate()
              .slideY(
            begin: -0.8,
            end: 0.0,
            duration: 1.seconds,
            curve: Curves.easeOut,
          )
              .then(delay: 1.seconds)
              .slideY(end: -0.1, duration: 900.milliseconds),

          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Basket is full!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: screenHeight * 0.005,),

                Text(
                  "Your basket has reached full capacity.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),

                Text(
                  "Please empty your basket.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: screenHeight * 0.2,),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 225,
                    child: Text(
                      "Return",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.15,)
              ],
            )
                .animate()
                .fadeIn(delay: 3.seconds, duration: 900.milliseconds)
          ),
        ],
      ),
    );
  }
}