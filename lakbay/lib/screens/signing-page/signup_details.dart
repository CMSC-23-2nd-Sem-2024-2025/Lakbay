import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakbay/screens/home-page/starting_page.dart';
import 'package:lakbay/screens/home-page/onboarding.dart';
import '../../providers/auth_provider.dart';

class SignupDetails extends StatefulWidget {
  const SignupDetails({super.key});

  @override
  State<SignupDetails> createState() => _SignupDetailsState();
}

class _SignupDetailsState extends State<SignupDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? prompt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
            
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 750,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBFBFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Create a new",
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const Text(
                            "account",
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // First Name
                          TextFormField(
                            controller: firstnameController,
                            decoration: const InputDecoration(
                              hintText: 'First Name',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please input a first name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(width: 30, height: 30),

                          // Last Name
                          TextFormField(
                            controller: lastnameController,
                            decoration: const InputDecoration(
                              hintText: 'Last Name',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please input a last name';
                              }
                              return null;
                            },
                          ),

                          SizedBox(width: 30, height: 30),

                          // Username (Optional / or required)
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please input a username!';
                              }
                              return null;
                            },
                          ),

                          SizedBox(width: 30, height: 30),

                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }

                              // More strict email validation pattern
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );

                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }

                              // Additional validation for common TLDs
                              final validTLDs = [
                                'com',
                                'org',
                                'net',
                                'edu',
                                'gov',
                                'mil',
                                'io',
                                'co',
                                'ai',
                                'app',
                                'dev',
                                'me',
                                'info',
                                'biz',
                                'name',
                                'pro',
                                'xyz',
                                'ph',
                                'uk',
                                'us',
                                'ca',
                                'au',
                                'nz',
                                'jp',
                                'kr',
                                'cn',
                                'in',
                                'sg',
                                'my',
                              ];

                              final tld =
                                  value.trim().split('.').last.toLowerCase();
                              if (!validTLDs.contains(tld)) {
                                return 'Please use a valid email domain';
                              }

                              if (prompt != null) {
                                final error = prompt;
                                prompt = null;
                                return error;
                              }
                              return null;
                            },
                          ),

                          SizedBox(width: 30, height: 30),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF86400),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              final specpw = RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$',
                              );
                              if (!specpw.hasMatch(value)) {
                                return 'Password too weak';
                              }
                              return null;
                            },
                          ),

                          const Spacer(),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String email = emailController.text.trim();
                                  String password =
                                      passwordController.text.trim();
                                  String firstName =
                                      firstnameController.text.trim();
                                  String lastName =
                                      lastnameController.text.trim();
                                  String username =
                                      usernameController.text.trim();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );

                                  String? result = await context
                                      .read<AuthProvider>()
                                      .signUp(
                                        email,
                                        password,
                                        firstName,
                                        lastName,
                                        username,

                                        friends: [],
                                        pendingRequests: [],
                                      );

                                  if (context.mounted) Navigator.pop(context);

                                  if (result != null) {
                                    setState(() {
                                      prompt = result;
                                    });
                                    _formKey.currentState!.validate();
                                  } else if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OnBoarding(),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFFF86400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Back Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed:
                                  () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StartingPage(),
                                    ),
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
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
