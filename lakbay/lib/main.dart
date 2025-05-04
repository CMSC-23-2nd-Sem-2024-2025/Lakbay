import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main(){
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(), // run the login page
        theme: ThemeData(
        
        textTheme: GoogleFonts.podkovaTextTheme(
          Theme.of(context).textTheme, // set the constant font style
        ),
      ),

    );
  }
}