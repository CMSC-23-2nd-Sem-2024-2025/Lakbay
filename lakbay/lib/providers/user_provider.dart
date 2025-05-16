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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    _planStream = firebaseService.getAllEntries(user.uid);
    notifyListeners();
  }
  }

  // this is the function for adding a new travel plan. makes a new instance of the travel plan (via the model)
  // and then calls the addEntry functio from the firebase user api to interact with the firebase

  Future<void> addPlan(TravelPlan plan) async {
     final planMap = {
      'userId': plan.userId,
      'travelName': plan.travelName,
      'location': plan.location,
      'departureDate': plan.departureDate.toIso8601String(),
      'returnDate': plan.returnDate.toIso8601String(),
      'flightDetails': plan.flightDetails,
      'accommodation': plan.accommodation,
      'notes': plan.notes,
      'emerContact': plan.emerContact,
    };

    // add the plan using await. omnce done, notify th listeners to update the UI
     final result = await firebaseService.addEntry(planMap);
    print(result);
    notifyListeners();
  }

  // funciton for edit. still not functional
  Future<void> editPlan(String id, TravelPlan updatedPlan) async {
    Map<String, dynamic> updatedData = updatedPlan.toJson();
    updatedData.remove('id'); // avoid updating the id field

    String message = await firebaseService.updateEntry(id, updatedData);
    print(message);
    notifyListeners();
  }

  // function for deleting a plan.

  Future<void> deletePlan(String id) async {

    // callls the  deleteEntry in the user api and deletes in the firebase
    String message = await firebaseService.deleteEntry(id);
    print(message);
    notifyListeners();
  }
}
