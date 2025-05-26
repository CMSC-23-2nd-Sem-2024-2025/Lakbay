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

  Future<String?> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null means success
    } on FirebaseAuthException catch (e) {
      
      return "Failed with error '${e.code}': ${e.message}";
    }
  }

  Future<String?> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String username, {
    String? phoneNumber,
    List<String> friends = const [],
    List<String> pendingRequests = const [],
  }) async {
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
      await db.collection("appusers").doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'userName': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'interests': [], // Initialize empty interests list
        'styles': [], // Initialize empty styles list
        'friends': friends, // Initialize friends list
        'pendingRequests': pendingRequests, // Initialize pending requests list
      });

      // will automatically signed in the user after signing up
      // ensure the user is signed in
      await auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
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
          await db.collection("appusers").doc(uid).get();

      if (newUserDoc.exists) {
        return newUserDoc.data() as Map<String, dynamic>;
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  Future<String?> updateUserInfo(
    String uid,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await db.collection("appusers").doc(uid).update(updatedData);
      return null; // null means success
    } catch (e) {
      
      return "Error updating user details: $e";
    }
  }
}

