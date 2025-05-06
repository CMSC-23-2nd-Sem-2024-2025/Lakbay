import 'package:exer08_tiamzon/screens/expenses_init_page.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
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
          return const SignInPage(); // navigate to Sign-In Page if no user is signed in
        }

        // condition: directs of there is already a user signed in
        // if the stream emits a user object
        return const ExpenseInitPage(); // navigate to ExpenseInitPage if user is signed in
      },
    );
  }
}
