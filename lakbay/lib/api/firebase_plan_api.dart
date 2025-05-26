import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePlanApi {

  // create instance of firebase firestore
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // stream function to get all entries for a user
  Stream<QuerySnapshot> getAllEntries(String userId) {
    return db.collection('travelplans').where('userId', isEqualTo: userId).snapshots();
  }


  // function to interact directly with firebase firestore to add entry. returns string
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
