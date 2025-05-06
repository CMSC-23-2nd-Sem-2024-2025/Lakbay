import 'package:flutter/material.dart';
import 'package:lakbay/screens/starting_page.dart';

class SignupDetails extends StatefulWidget {
  const SignupDetails({super.key});

  @override
  State<SignupDetails> createState() => SignupDetailsState();
}

class SignupDetailsState extends State<SignupDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          "SIGN UP",
                          style: TextStyle(
                            color: Color(0xFF5F7CF6),
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          "CREATE YOUR ACCOUNT",
                          style: TextStyle(
                            color: Color(0xFF8DA2E6),
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 40),

                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'First Name',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5F7CF6)),
                            ),
                          ),
                        ),

                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5F7CF6)),
                            ),
                          ),
                        ),

                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Username',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5F7CF6)),
                            ),
                          ),
                        ),

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
                              "Sign up",
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StartingPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: BorderSide.none,
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
