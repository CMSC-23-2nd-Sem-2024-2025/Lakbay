import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exer08_tiamzon/api/firebase_expenses_api.dart';
import 'package:flutter/material.dart';

class ExpenseListProvider with ChangeNotifier {
  // todostream for returning the value of db collection todos snapshot
  // use to return sequence of events
  // listens the changes na nangyari (dinelete the data)
  FirebaseTodoAPI firebaseService = FirebaseTodoAPI();
  Stream<QuerySnapshot>? _todosStream;

  ExpenseListProvider() {
    firebaseService = FirebaseTodoAPI();
    fetchTodos();
  }

  // getter
  Stream<QuerySnapshot>? get expenses => _todosStream;

  // TODO: get all expenses items from Firestore
  void fetchTodos() {
    _todosStream = firebaseService.getAllTodos(); // Fetch filtered expenses
    notifyListeners();
  }

  // TODO: add expenses item and store it in Firestore
  void addTodo(Map<String, dynamic> expense) async {
    String message = await firebaseService.addTodo(expense);
    print(message); // Log the result
    notifyListeners(); // Notify listeners to update the UI
  }

  // TODO: edit a expenses item and update it in Firestore
  Future<void> editTodo(String id, Map<String, dynamic> updatedFields) async {
    String message = await firebaseService.editTodo(id, updatedFields);
    print(message);
    notifyListeners();
  }

  // TODO: delete a expenses item and update it in Firestore
  Future<void> deleteTodo(String id) async {
    String message = await firebaseService.deleteTodo(id);
    print(message);
    notifyListeners();
  }

  // TODO: modify a expenses status and update it in Firestore
  Future<void> toggleStatus(String id, bool status) async {
    String message = await firebaseService.toggleStatus(id, status);
    print(message);
    notifyListeners();
  }
}
