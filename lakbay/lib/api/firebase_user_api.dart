import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseExpenseApi {

  final FirebaseFirestore db = FirebaseFirestore.instance;
   String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Stream <QuerySnapshot>getAllEntries(){
    
    return db.collection('appusers').doc(uid).collection('plans').snapshots();
    
  }

  Future<String> addEntry(Map<String, dynamic> entry) async{
    try{
      final userExpenser = db.collection('appusers').doc(uid).collection('plans').doc();

      entry['id'] = userExpenser.id;
      await userExpenser.set(entry);

    return "Successfully added Expense!";
    } on FirebaseException catch (e){
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<String> deleteEntry(String id) async{
    try{


    
      await db.collection('users').doc(uid).collection('expenses').doc(id).delete();

    return "Successfully deleted todo!";
    } on FirebaseException catch (e){
      return "Error on ${e.code}: ${e.message}";
    }
  }

  Future<String> updateEntry(String id, Map<String, dynamic> updatedData) async {
    try {
      await db.collection('users').doc(uid).collection('expenses').doc(id).update(updatedData);
      return "Successfully updated expense!";
    } on FirebaseException catch (e) {
      return "Error on ${e.code}: ${e.message}";
    }
  }

  
}