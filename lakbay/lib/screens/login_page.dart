import 'package:flutter/material.dart';
import 'package:lakbay/components/text_form_field.dart';

class LoginPage extends StatefulWidget {


  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

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

                SizedBox(height: 20),
                // logo
                Image.asset('assets/logo.png', 
                height: 350.67,
                ),

                //email textfield
                
                TextformField(hintText: "Username", obscureText: false, controller: emailController, icon: Icon(Icons.person)),

                TextformField(hintText: "Password", obscureText: true, controller: passwordController, icon: Icon(Icons.lock)),




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
