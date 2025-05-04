import 'package:flutter/material.dart';
import 'package:lakbay/components/buttons.dart';
import 'package:lakbay/components/text_form_field.dart';

// make a stateful widget of the log in page
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // text editing controller for email and password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F6D5E),
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
                Image.asset(
                  'assets/logo.png',
                  height: 350.67,
                ),

                // add email text field field (this is not a formfield yet)
                TextformField(
                    hintText: "Username",
                    obscureText: false,
                    controller: emailController,
                    icon: Icon(Icons.person)),

                  // add password text field (this is not a formfield yet)
                TextformField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController,
                    icon: Icon(Icons.lock)),
              ],
            ),
          ),
        ),
      ),

      // set animation for the container
      bottomNavigationBar: TweenAnimationBuilder(
        tween: Tween<Offset>(
          begin: Offset(0, 1), // start off screen
          end: Offset(0, 0),   // end on the current position
        ),
        duration: Duration(milliseconds: 2000), // animation will take 2 secs
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(0,offset.dy * MediaQuery.of(context).size.height), // vertical multiplied by the size of the screen for it to go forward frame by frame
            child: Container(
              width: double.infinity, // make the container extend to the sides
              height: 325, // set a height
              decoration: BoxDecoration(
                color: Color(0xFFE7F4EA), // add color and make the edges circular
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),

              child: Column(
                children:[

                  SizedBox(height: 40),

                  // log in button

                  MyButtons(label: "Log in", color: Color(0xFF7BC678), onPressed: (){

                    // wala pa implementation
                  
                  }),

                  SizedBox(height: 10),

                  Text("or", style: TextStyle(fontSize: 26),),

                  SizedBox(height: 10),

                  // sign up button

                  MyButtons(label: "Sign up", color: Color(0xFF7BC678), onPressed: (){

                    // wala pa implementation
                  
                  }),

                  
                ]

              ),
            ),
          );
        },
      ),
    );
  }
}
