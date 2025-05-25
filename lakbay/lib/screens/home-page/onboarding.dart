import 'package:flutter/material.dart';
import 'package:lakbay/components/scaffolds.dart';
import 'package:lakbay/screens/intro_screens/interests.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lakbay/screens/intro_screens/stylers.dart';
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

  // check if it is in the last page to set state on some widgets 
  bool onLastPage = false;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        // apply stack since the screens are on top of each other
        child: Stack(
          children: [

            // add the page view so switch between the pages
            PageView(
              onPageChanged: (index) {
                setState(() { // since dalawa lang page, then the last page is 1
                  onLastPage = (index == 1);
                });
              },
              controller: _controller,
              children: [
                // will lead to the interests screen
                InterestsPage(
                  onInterestsSelected: (interests) {
                    setState(() {
                      selectedInterests = interests;
                      // get the intersts from the intersts page
                    });
                  },
                ),

                // lead to styles screen
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
                  
                  // gesture detector for the back buttn
                  GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },

                    child: const Text("Back", style: TextStyle(fontSize: 18)),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Always push to MainScaffold
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScaffold(),
                        ),
                      );
                    },
                    child: Text(
                      onLastPage ? "Done" : "Skip",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              // position the buttona the bottom
              bottom: 80, 
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // adjust the hegiht of teh button
                    width: 315,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (onLastPage) {
                          // debugging
                          print(selectedInterests);
                          print(selectedStyles);

                          // make an instance of the auth provider to check the current logged in user. if there is a user,
                          // store the intersts and styles in the attributes of the user in the firebase (can also store empty) 
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final user = authProvider.userObj;

                          if (user != null) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('appusers')
                                  .doc(user.uid)
                                  .update({
                                    'interests':
                                        selectedInterests.isEmpty
                                            ? []
                                            : selectedInterests,
                                    'styles':
                                        selectedStyles.isEmpty
                                            ? []
                                            : selectedStyles,
                                  });

                              print("success");
                            } catch (e) {
                              print("Failed to update user data: $e");
                            }
                          } else {
                            print("no user found");
                          }

                          // proceed to home page

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScaffold(),
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
