import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// dito ilalagay lahat ng files na icoconnect sa firebase
// gamit front-end code
class FirebaseTodoAPI {
  // use this instance to manage the data sa firebase
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // future object had to do asynchronous function
  // hindi siya line by line na natatapos sa pag-execute
  // kailangan niyang hintayin na makuha yung data and maconnect sa firebase
  // bago matapos

  // map since naka json format
  // specified na strings yung data type, and dynamic since completed is boolean

  // ginagawa nito is nirereference niya yung id (optional id) sa collection
  // nacocopy yung nagenereate na id sa add document section
  // dapat consitent sa pag iimplement
  //expenses['id'] = db.collection("expensestracker").doc(expenses['id']).set(expenses);

  Future<String> addTodo(Map<String, dynamic> expenses) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        return "User not authenticated.";
      }

      expenses['id'] =
          db.collection('expensestracker').doc().id; // Generate unique ID
      expenses['userId'] = userId; // add userId to the expense data

      await db
          .collection("expensestracker")
          .doc(expenses['id'])
          .set(expenses); // Save to Firestore
      return "Successfully added expenses!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteTodo(String id) async {
    try {
      await db.collection("expensestracker").doc(id).delete();

      return "Successfully deleted expenses!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  // even there are different users id
  // changes will be reflected based on the id of the expensestracker
  // updatedFields -- updates only the fields that are present in the document
  Future<String> editTodo(String id, Map<String, dynamic> updatedFields) async {
    try {
      if (updatedFields.containsKey('category')) {
        updatedFields['category'] =
            updatedFields['category'].toString().split('.').last;
      }
      await db.collection("expensestracker").doc(id).update(updatedFields);

      return "Successfully updated expenses!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> toggleStatus(String id, bool status) async {
    try {
      await db.collection("expensestracker").doc(id).update({"paid": status});

      return "Successfully updated paid status!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  // this displays the expenses for a specific category
  // where clause is used to filter out the data in the collection
  // where the category field matches from the chosen category value
  // snapshot() is a listener that displays real-time updates
  Future<Stream<QuerySnapshot>> getExpensesByCatgory(String category) async {
    return db
        .collection("expensestracker")
        .where("category", isEqualTo: category)
        .snapshots();
  }

  // querysnapshot is a built-in object sa firestore
  // ito yung data type for stream of snaphots
  // snaphots - nagrerefer ng current na laman ng stream in certain period of time
  Stream<QuerySnapshot> getAllTodos() {
    // get the current user ID
    // filters the expenses by userId of the current signed-in user

    // currentUser is a instance of the FirebaseAuth (package)
    // uid - user's unique id came from firebase auth package
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated.");
    }

    // filter expenses by userId
    return db
        .collection("expensestracker")
        // where method is used to filter the data in the collection based on a certain conditions
        // .where(field, isEqualTo: value)
        // field - field name in the collection
        // retrieves all the documents based on the collection name (expensestracker)
        // and filters the documents where the userId field matches the current user's ID
        .where("userId", isEqualTo: userId)
        .snapshots();
  }
}
