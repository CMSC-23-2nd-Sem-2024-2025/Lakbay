import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lakbay/screens/signing-page/login_details.dart';
import 'package:lakbay/screens/signing-page/signup_details.dart';
import 'package:animations/animations.dart';

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
    final size = MediaQuery.of(context).size;
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
                    fontSize: size.height * 0.030,
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
        tween: Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)),
        duration: Duration(milliseconds: 700),
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(0, offset.dy * size.height),
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.38, // 38% of screen height
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 254, 202, 141),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * 0.18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.height * 0.32, // 32% of screen height
                    decoration: BoxDecoration(
                      color: Color(0xFFF86400),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * 0.18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Log In Button
                        SizedBox(
                          width: size.width * 0.8,
                          height: size.height * 0.08,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 400),
                                  pageBuilder: (context, animation, secondaryAnimation) => const LoginDetails(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SharedAxisTransition(
                                      animation: animation,
                                      secondaryAnimation: secondaryAnimation,
                                      transitionType: SharedAxisTransitionType.horizontal,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF020B1B),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: size.height * 0.025,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.025),
                        // Sign Up Button
                        SizedBox(
                          width: size.width * 0.8,
                          height: size.height * 0.08,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 400),
                                  pageBuilder: (context, animation, secondaryAnimation) => const SignupDetails(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SharedAxisTransition(
                                      animation: animation,
                                      secondaryAnimation: secondaryAnimation,
                                      transitionType: SharedAxisTransitionType.horizontal,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Colors.white, width: 2),
                              backgroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: size.height * 0.025,
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
