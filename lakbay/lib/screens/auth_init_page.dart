import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:lakbay/screens/home_page.dart';
import 'package:lakbay/screens/login_details.dart';
import 'package:lakbay/screens/starting_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signin_page.dart';

class AuthenticationInitPage extends StatefulWidget {
  const AuthenticationInitPage({super.key});

  @override
  State<AuthenticationInitPage> createState() => _AuthInitPage();
}

class _AuthInitPage extends State<AuthenticationInitPage> {
  @override
  Widget build(BuildContext context) {
    // used context.read to get the stream once
    // to avoid unecessary rebuilds

    // listens to the authentication state changes
    Stream<User?> userStream = context.read<AuthProvider>().userStream;

    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error encountered! ${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // condition: checks if there is all ready a user signed in
        // if the stream emits null
        if (!snapshot.hasData) {
          return StartingPage(); // navigate to Sign-In Page if no user is signed in
        }

        // condition: directs of there is already a user signed in
        // if the stream emits a user object
        return const HomePage(); // navigate to ExpenseInitPage if user is signed in
      },
    );
  }
}
