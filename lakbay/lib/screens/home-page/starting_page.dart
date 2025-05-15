import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lakbay/screens/signing-page/login_details.dart';
import 'package:lakbay/screens/signing-page/signup_details.dart';

// make a stateful widget of the log in page
class StartingPage extends StatefulWidget {
  const StartingPage({super.key});

  @override
  State<StartingPage> createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  // text editing controller for email and password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      // safe area as body for the widgets to not overflow outside
      body: SafeArea(
        child: SingleChildScrollView(
          // make the screen scrollable to avoid overflow
          child: Padding(
            // add padding
            padding: EdgeInsets.symmetric(horizontal: 25),

            // this is the first half of the log in page with padding to keep it on the middle
            child: Column(
              children: [
                // add the logo
                SizedBox(height: 20),
                Image.asset('assets/or.png', height: 350.67),

                Text(
                  "Plan your\nnext journey with us!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 500.ms).fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),

      // set animation for the container
      bottomNavigationBar: TweenAnimationBuilder(
        tween: Tween<Offset>(
          begin: Offset(0, 1), // start off screen
          end: Offset(0, 0), // end on the current position
        ),
        duration: Duration(milliseconds: 700), // animation will take 2 secs
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(
              0,
              offset.dy * MediaQuery.of(context).size.height,
            ), // vertical multiplied by the size of the screen for it to go forward frame by frame
            child: Stack(
              children: [
                Container(
                  height: 395,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      254,
                      202,
                      141,
                    ), // add color and make the edges circular
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(80),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width:
                        double
                            .infinity, // make the container extend to the sides
                    height: 340, // set a height
                    decoration: BoxDecoration(
                      color: Color(
                        0xFFF86400,
                      ), // add color and make the edges circular
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80),
                      ),
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 80),

                        // log in button
                        SizedBox(
                          width: 315,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginDetails(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              // side: BorderSide(
                              //   color: Color(),
                              //   width: 2,
                              // ),
                              backgroundColor: Color(0xFF020B1B),
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

                        SizedBox(height: 20),

                        // sign up button
                        SizedBox(
                          width: 315,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupDetails(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFFFFFFFF),
                                width: 2,
                              ),
                              backgroundColor: Color(0xFFFFFFFF),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Sign Up", // Capitalized "In" for consistency
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF020B1B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
