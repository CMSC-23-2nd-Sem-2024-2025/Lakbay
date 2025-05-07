import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                heading,
                firstNameField,
                lastNameField,
                emailField,
                passwordField,
                submitButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get heading => const Padding(
    padding: EdgeInsets.only(bottom: 30),
    child: Text(
      "Sign Up",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  );

  Widget get firstNameField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("First Name"),
        hintText: "Enter a valid first name",
      ),
      onSaved: (value) => setState(() => firstName = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid first name";
        }
        return null;
      },
    ),
  );

  Widget get lastNameField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Last Name"),
        hintText: "Enter a valid last name",
      ),
      onSaved: (value) => setState(() => lastName = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid last name";
        }
        return null;
      },
    ),
  );

  Widget get emailField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Email"),
        hintText: "Enter a valid email",
      ),
      onSaved: (value) => setState(() => email = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid email format";
        }

        if (!isValidEmail(value)) {
          return "Please enter a valid email format";
        }

        return null;
      },
    ),
  );

  Widget get passwordField => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Password"),
        hintText: "At least 6 characters",
      ),
      obscureText: true,
      onSaved: (value) => setState(() => password = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a valid password";
        }

        // password format validation
        if (!_validatePassword(value)) {
          return _errorMessage;
        }
        return null;
      },
    ),
  );

  Widget get submitButton => ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (email == null ||
            password == null ||
            firstName == null ||
            lastName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill in all fields")),
          );
          return;
        }

        String result = await context.read<AuthProvider>().authService.signUp(
          email!,
          password!,
          firstName!,
          lastName!,
        );

        if (result == "Successfully signed up!") {
          if (mounted) Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result)));
        }
      }
    },
    child: const Text("Sign Up"),
  );

  // Function to validate the password
  // reference: https://www.geeksforgeeks.org/flutter-handle-textfield-validation-in-password/
  bool _validatePassword(String password) {
    // Reset error message
    _errorMessage = '';

    // Password length greater than 6
    if (password.length < 6) {
      _errorMessage += 'Password must be longer than 6 characters.\n';
    }

    // Contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += '• Uppercase letter is missing.\n';
    }

    // Contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += '• Lowercase letter is missing.\n';
    }

    // Contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += '• Digit is missing.\n';
    }

    // Contains at least one special character
    if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += '• Special character is missing.\n';
    }

    // If there are no error messages, the password is valid
    return _errorMessage.isEmpty;
  }

  // using regex for validating email format
  bool isValidEmail(String email) {
    // Basic email format validation using regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return false; // Fails basic email format validation
    }

    // List of valid TLDs
    final validTlds = ['.com', '.org', '.net', '.edu', '.gov', '.io', '.co'];

    // Check if the email ends with a valid TLD
    if (!validTlds.any((tld) => email.endsWith(tld))) {
      return false; // Invalid TLD
    }

    return true; // Email is valid
  }
}
