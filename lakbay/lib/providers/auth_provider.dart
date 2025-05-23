import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../api/firebase_auth_api.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> uStream;
  User? userObj;
  Map<String, dynamic>? userDetails;

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

  Future<void> fetchUserDetails() async {
    // current user logged in to the app
    User? currentUser = FirebaseAuthAPI.auth.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      Map<String, dynamic>? userDetails = await FirebaseAuthAPI()
          .getNewUserInfo(uid);

      // this is for debugging only.
      if (userDetails != null) {
        userObj = currentUser;
        this.userDetails = userDetails;
        print("First Name: ${userDetails['firstName']}");
        print("Last Name: ${userDetails['lastName']}");
        print("Email: ${userDetails['email']}");
        notifyListeners(); // Add this line to notify listeners after updating userDetails
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
    String username, {
    String? phoneNumber,
  }) async {
    // Call the auth service and store the result
    String? result = await authService.signUp(
      email,
      password,
      firstName,
      lastName,
      username,
      phoneNumber: phoneNumber,
    );

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

  Future<String?> updateUserDetails(Map<String, dynamic> updatedData) async {
    User? currentUser = FirebaseAuthAPI.auth.currentUser;
    if (currentUser != null) {
      // check if user is logged in
      String uid = currentUser.uid;
      String? result = await authService.updateUserInfo(
        uid,
        updatedData,
      ); // update user details
      if (result == null) {
        await fetchUserDetails(); // refresh details after update
        notifyListeners(); // notify listeners of the state change
      }
      return result;
    }
    return "No user is currently signed in.";
  }
}
