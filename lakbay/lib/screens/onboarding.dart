import 'package:flutter/material.dart';
import 'package:lakbay/intro_screens/interests.dart';
import 'package:lakbay/screens/profile_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lakbay/intro_screens/stylers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lakbay/providers/auth_provider.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnBoarding> {
  // page controller
  List<String> selectedInterests = [];
  List<String> selectedStyles = [];

  bool onLastPage = false;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == 1);
                });
              },
              controller: _controller,
              children: [
                InterestsPage(
                  onInterestsSelected: (interests) {
                    setState(() {
                      selectedInterests = interests;
                    });
                  },
                ),
                StylePage(
                  onStylesSelected: (styles) {
                    setState(() {
                      selectedStyles = styles;
                    });
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top-left widget (e.g., a back button or title)
                  GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },

                    child: const Text("Back", style: TextStyle(fontSize: 18)),
                  ),

                  onLastPage
                      ? GestureDetector(
                        onTap: () {},

                        child: const Text(
                          "Done",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                      : // Top-right "Skip" button
                      GestureDetector(
                        onTap: () {},

                        child: const Text(
                          "Skip",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                ],
              ),
            ),

            Positioned(
              bottom: 80, // Adjust this value to your preference
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 315,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onLastPage) {
                          print(selectedInterests);
                          print(selectedStyles);

                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final user = authProvider.userObj;

                          // if (user != null){

                          //   try {

                          //   }
                          // }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        } else {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF86400),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        onLastPage ? "Finish" : "Next",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20), // Space between text and indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 2,
                    effect: WormEffect(activeDotColor: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
