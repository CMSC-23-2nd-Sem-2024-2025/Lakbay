import 'package:flutter/material.dart';
import 'package:lakbay/providers/auth_provider.dart';
import 'package:lakbay/screens/home-page/starting_page.dart';
import 'package:provider/provider.dart';
import 'package:lakbay/components/scaffolds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginDetails extends StatefulWidget {
  const LoginDetails({super.key});

  @override
  State<LoginDetails> createState() => _LoginDetailsState();
}

class _LoginDetailsState extends State<LoginDetails> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool showSignInErrorMessage = false;
  bool showEmailErrorMessage = false;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 750,
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Log in to your",
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            "account",
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          SizedBox(height: 40),

                          // Email TextFormField
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Email',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Enter your email'
                                        : null,
                            onSaved: (value) => email = value,
                          ),
                          if (showEmailErrorMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Email does not exist',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          SizedBox(width: 30, height: 30),

                          // Password TextFormField
                          TextFormField(
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Enter your password'
                                        : null,
                            onSaved: (value) => password = value,
                          ),
                          if (showSignInErrorMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Incorrect password',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          // Spacer to push button to the bottom
                          Spacer(),

                          // Log In Button
                          SizedBox(
                            width: 315,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  String? message = await context
                                      .read<AuthProvider>()
                                      .signIn(email!, password!);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  print('Error code: $message'); // Debug print

                                  setState(() {
                                    if (message == 'user-not-found' ||
                                        message == 'invalid-email') {
                                      showEmailErrorMessage = true;
                                      showSignInErrorMessage = false;
                                    } else if (message == 'wrong-password' ||
                                        message == 'invalid-credential') {
                                      showEmailErrorMessage = false;
                                      showSignInErrorMessage = true;
                                    } else {
                                      showEmailErrorMessage = false;
                                      showSignInErrorMessage = false;
                                    }
                                  });

                                  // Navigate to the homepage if login is successful
                                  if (message == null) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const MainScaffold(),
                                      ),
                                      (route) => false,
                                    );
                                  }
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
                                "Log In",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 315,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartingPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide.none,
                                ),
                              ),
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
