

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePlanApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllEntries(String userId) {
    return db.collection('travelplans').where('userId', isEqualTo: userId).snapshots();
  }

  Future<String> addEntry(Map<String, dynamic> entry) async {
    try {
      
      final planDoc = db.collection('travelplans').doc();
      entry['id'] = planDoc.id;
      await planDoc.set(entry);
      
      return "Successfully added Plan!";
    } on FirebaseException catch (e) {
      
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<String> deleteEntry(String id) async {
    try {
      await db.collection('travelplans').doc(id).delete();
      return "Successfully deleted Plan!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<String> updateEntry(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await db.collection('travelplans').doc(id).update(updatedData);
      return "Successfully updated Plan!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }
}
