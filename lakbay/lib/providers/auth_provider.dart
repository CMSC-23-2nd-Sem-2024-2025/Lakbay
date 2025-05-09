import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../api/firebase_auth_api.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> uStream;
  User? userObj;

  AuthProvider() {
    authService =
        FirebaseAuthAPI(); // need to hide because of the conflicting name
    fetchAuthentication();
  }

  Stream<User?> get userStream => uStream;

  void fetchAuthentication() {
    uStream =
        authService
            .getUser(); // returns the current authentication state of a user

    uStream.listen((user) {
      // listens the changes in authentication state
      if (user == null) {
        print("No user is currently signed in.");
      } else {
        print("Auth state changed: ${user.email}");
      }
      if (userObj != user) {
        userObj = user; // Update the user object
        notifyListeners(); // Notify listeners of the state change
      }
    });
  }

  
  Future<void> fetUserDetails() async {
    // current user logged in to the app
    User? currentUser = FirebaseAuthAPI.auth.currentUser;

    if (currentUser != null) {
      
      String uid = currentUser.uid;

      Map<String, dynamic>? userDetails = await FirebaseAuthAPI()
          .getNewUserInfo(uid);

      // this is for debugging only.
      if (userDetails != null) {
        print("First Name: ${userDetails['firstName']}");
        print("Last Name: ${userDetails['lastName']}");
        print("Email: ${userDetails['email']}");
      } else {
        print("User details not found in Firestore.");
      }
    }
  }

  Future<String?> signUp(
  String email,
  String password,
  String firstName,
  String lastName,
) async {
  // Call the auth service and store the result
  String? result = await authService.signUp(email, password, firstName, lastName);
  
  // Notify listeners after the sign-up attempt
  notifyListeners();
  
  // Return the result (which could be an error message or null)
  return result;
}

  Future<String?> signIn(String email, String password) async {
    final result = await authService.signIn(email, password);
    notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }

  Future<void> signUpUser(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    String result = await FirebaseAuthAPI().signUp(
      email,
      password,
      firstName,
      lastName,
    );

    if (result == "Sucessfully signed up!") {
      print("User signed up and details saved in Firestore");
    } else {
      print(result);
    }
  }
}

