import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePlanApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> getAllEntries() {
    return db.collection('appusers').doc(uid).collection('plans').snapshots();
  }

  Future<String> addEntry(Map<String, dynamic> entry) async {
  try {
    print("Attempting to add entry: $entry");
    final userPlanDoc = db.collection('appusers').doc(uid).collection('plans').doc();
    entry['id'] = userPlanDoc.id;
    await userPlanDoc.set(entry);
    print("Successfully added entry: $entry");
    return "Successfully added Plan!";
  } on FirebaseException catch (e) {
    print("Error adding plan: ${e.code} - ${e.message}");
    return "Error on ${e.code}: ${e.message}";
  }
}

  Future<String> deleteEntry(String id) async {
    try {
      await db.collection('appusers').doc(uid).collection('plans').doc(id).delete();
      return "Successfully deleted Plan!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<String> updateEntry(String id, Map<String, dynamic> updatedData) async {
    try {
      await db.collection('appusers').doc(uid).collection('plans').doc(id).update(updatedData);
      return "Successfully updated Plan!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }
}
