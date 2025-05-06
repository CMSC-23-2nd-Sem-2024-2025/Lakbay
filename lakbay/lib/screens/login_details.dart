import 'package:flutter/material.dart';

class LoginDetails extends StatefulWidget {
  const LoginDetails({super.key});

  @override
  State<LoginDetails> createState() => _LoginDetailsState();
}

class _LoginDetailsState extends State<LoginDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5F7CF6),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Bottom layer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 800,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8DA2E6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                    ),
                  ),
                ),
              ),

              // Top layer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 750,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBFBFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                    ),
                  ),

                  child: Padding(

                    padding: EdgeInsets.all(50),

                    child: Column(
                    

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text("LOG IN", style: TextStyle(
                        color: Color(0xFF5F7CF6),
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        
                        )),

                      Text("FOR YOUR ACCOUNT", 
                      style: TextStyle(
                        color: Color(0xFF8DA2E6),
                        fontSize: 25,
                      )),

                      


                    ],
                  )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
