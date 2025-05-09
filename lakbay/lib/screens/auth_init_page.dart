import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:lakbay/screens/home_page.dart';
import 'package:lakbay/screens/login_details.dart';
import 'package:lakbay/screens/starting_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';


class AuthenticationInitPage extends StatefulWidget {
  const AuthenticationInitPage({super.key});

  @override
  State<AuthenticationInitPage> createState() => _AuthInitPage();
}

class _AuthInitPage extends State<AuthenticationInitPage> {
  @override
  Widget build(BuildContext context) {
    
    //this checks if the user is currently logged in. if not, return to startingpage. this 
    // this is done to save account
    Stream<User?> userStream = context.read<AuthProvider>().userStream;

    return StreamBuilder<User?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return StartingPage(); // No user signed in
        }

        return const HomePage(); // User signed in
      },
    );
  }
}
