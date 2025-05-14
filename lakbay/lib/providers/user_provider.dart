// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ex8/api/firebase_todo_api.dart';
// import 'package:flutter/material.dart';
// import '../../../../models/todo_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EntryExpenseProvider with ChangeNotifier {
//   Stream<QuerySnapshot>? _expenseStream;

//   //this gets an the stream of the firebase and shares it throughout the app.
//   // I added the auth also in the expense provider because it constantly listens to the current logged in user

//   Stream<QuerySnapshot>? get expenses => _expenseStream;

//   final FirebaseExpenseApi firebaseService = FirebaseExpenseApi();

//   EntryExpenseProvider() {
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user != null) {
//         fetchExpense();
//       } else {
//         _expenseStream = null;
//         notifyListeners();
//       }
//     });
//   }
//   // this is the provider file

//   void fetchExpense() {
//     _expenseStream = firebaseService.getAllEntries();

//     notifyListeners();
//   }

//   Future<void> addExpense(ExpenseEntry item) async {
//     String message = await firebaseService.addEntry(item.toJson());
//     print(message);
//     notifyListeners();
//   }

//   Future<void> editExpense(String id, ExpenseEntry updatedExpense) async {
//     Map<String, dynamic> updatedData = {
//       'name': updatedExpense.name,
//       'description': updatedExpense.description,
//       'category': updatedExpense.category,
//       'amount': updatedExpense.amount,
//     };

//     String message = await firebaseService.updateEntry(id, updatedData);
//     print(message);
//     notifyListeners();
//   }

//   Future<void> deleteTodo(String id) async {
//     String message = await firebaseService.deleteEntry(id);
//     print(message);
//     notifyListeners();
//   }

//   Future<void> toggleStatus(String id, bool currentPaidStatus) async {
//     bool newPaidStatus = !currentPaidStatus;

//     Map<String, dynamic> updatedData = {'paid': newPaidStatus};

//     String message = await firebaseService.updateEntry(id, updatedData);
//     print(message);
//     notifyListeners();
//   }
// }
