import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/api/firebase_user_api.dart';
import 'package:lakbay/models/travel_plans_model.dart';



class PlanProvider with ChangeNotifier {
  Stream<QuerySnapshot>? _planStream;

  // Stream getter to expose plans collection snapshots
  Stream<QuerySnapshot>? get plans => _planStream;

  final FirebasePlanApi firebaseService = FirebasePlanApi();

  PlanProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchPlans();
      } else {
        _planStream = null;
        notifyListeners();
      }
    });
  }

  void fetchPlans() {
    _planStream = firebaseService.getAllEntries();
    notifyListeners();
  }

  Future<void> addPlan(TravelPlan plan) async {
    String message = await firebaseService.addEntry(plan.toJson());
    print(message);
    notifyListeners();
  }

  Future<void> editPlan(String id, TravelPlan updatedPlan) async {
    Map<String, dynamic> updatedData = updatedPlan.toJson();
    updatedData.remove('id'); // avoid updating the id field

    String message = await firebaseService.updateEntry(id, updatedData);
    print(message);
    notifyListeners();
  }

  Future<void> deletePlan(String id) async {
    String message = await firebaseService.deleteEntry(id);
    print(message);
    notifyListeners();
  }
}
