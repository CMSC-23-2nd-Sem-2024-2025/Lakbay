import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F6D5E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
              children: [
                // logo
                Image.asset('assets/logo.png', 
                height: 350.67,
                ),

                //email textfield
                Text("Login"),

                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "username",
                    border: OutlineInputBorder(),
                  )
                ),


                //password textfield

                //sign in button

                //sign up button
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
