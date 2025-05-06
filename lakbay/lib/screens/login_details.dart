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
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LOG IN",
                          style: TextStyle(
                            color: Color(0xFF5F7CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          "FOR YOUR ACCOUNT",
                          style: TextStyle(
                            color: Color(0xFF8DA2E6),
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 40),

                        // Email TextFormField
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5F7CF6)),
                            ),
                          ),
                        ),

                        // Password TextFormField
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5F7CF6)),
                            ),
                          ),
                        ),

                        // Spacer to push button to the bottom
                        Spacer(),

                        // Log In Button
                        SizedBox(
                          width: 315,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5F7CF6),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 315,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, 
                              shadowColor: Colors.transparent, 
                              elevation: 0, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side:
                                    BorderSide.none, 
                              ),
                            ),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF000000), 

                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
