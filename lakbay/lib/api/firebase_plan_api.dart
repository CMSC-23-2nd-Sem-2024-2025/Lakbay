import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePlanApi {
  // create instance of firebase firestore
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // stream function to get all entries for a user
  Stream<QuerySnapshot> getAllEntries(String userId) {
    return db
        .collection('travelplans')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // function to interact directly with firebase firestore to add entry. returns string
  Future<String> addEntry(Map<String, dynamic> entry) async {
    try {
      print('FirebasePlanApi: Adding entry to Firestore');
      print('Entry data: $entry');

      final planDoc = db.collection('travelplans').doc();
      entry['id'] = planDoc.id;

      print('FirebasePlanApi: Setting document with ID: ${planDoc.id}');
      await planDoc.set(entry);
      print('FirebasePlanApi: Document set successfully');

      return "Successfully added Plan!";
    } on FirebaseException catch (e) {
      print('FirebasePlanApi: Error adding entry: ${e.code}: ${e.message}');
      return "Error on ${e.code}: ${e.message}";
    } catch (e) {
      print('FirebasePlanApi: Unexpected error: $e');
      return "Unexpected error: $e";
    }
  }

  // delete entry function, takes id as parameter. returns string
  Future<String> deleteEntry(String id) async {
    try {
      await db.collection('travelplans').doc(id).delete();
      return "Successfully deleted Plan!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  // update entry function, takes id and updated data as parameters. returns string
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
