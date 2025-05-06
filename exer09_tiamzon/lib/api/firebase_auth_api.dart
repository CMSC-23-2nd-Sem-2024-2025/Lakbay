import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db =
      FirebaseFirestore
          .instance; // for addtional user information (first and last name)

  Stream<User?> getUser() {
    return auth.authStateChanges();
  }

  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return "Successfully signed in!";
    } on FirebaseAuthException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      // create user in firebase authentication
      // creates new user firebase account
      // UserCredential class from firebase_auth package
      UserCredential newUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // get the user's UID
      String uid = newUser.user!.uid;

      // additional user details in Firestore
      // new user will be added in the userexpense collection
      // and the document ID will be the user's UID
      await db.collection("userexpense").doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      });

      // will automatically signed in the user after signing up
      // ensure the user is signed in
      await auth.signInWithEmailAndPassword(email: email, password: password);

      print("User created in Firebase Authentication: $uid");
      print("User details saved in Firestore.");

      return "Successfully signed up!";
    } on FirebaseAuthException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    }
  }

  Future<String> signOut() async {
    await auth.signOut();
    return "Successfully signed out!";
  }

  Future<Map<String, dynamic>?> getNewUserInfo(String uid) async {
    try {
      DocumentSnapshot newUserDoc =
          await db.collection("userexpense").doc(uid).get();

      if (newUserDoc.exists) {
        return newUserDoc.data() as Map<String, dynamic>;
      } else {
        print("User document does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }
}

// TODO: addtional information for user
/*
api for getting addtional information
- first name 
- last name
 */
