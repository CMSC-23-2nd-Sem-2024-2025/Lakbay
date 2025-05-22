import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/api/firebase_shared_plans_api.dart';
import 'package:lakbay/models/shared_plans_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharedPlansProvider with ChangeNotifier {
  final FirebaseSharedPlansApi _sharedPlansApi = FirebaseSharedPlansApi();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of SharedPlan objects shared by the current user
  Stream<List<SharedPlan>> get plansSharedByMe {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _sharedPlansApi.getPlansSharedBy(userId);
  }

  // Stream of SharedPlan objects shared with the current user
  Stream<List<SharedPlan>> get plansSharedWithMe {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _sharedPlansApi.getPlansSharedWith(userId);
  }

  // Add a shared plan (share a plan with another user by userId)
  Future<String> addSharedPlan(SharedPlan sharedPlan) async {
    final id = await _sharedPlansApi.addSharedPlan(sharedPlan);
    notifyListeners();
    return id;
  }

  // Update a shared plan (e.g., revoke or change permissions)
  Future<void> updateSharedPlan(
    String sharedPlanId,
    Map<String, dynamic> updates,
  ) async {
    await _sharedPlansApi.updateSharedPlan(sharedPlanId, updates);
    notifyListeners();
  }

  // Delete a shared plan (revoke sharing)
  Future<void> deleteSharedPlan(String sharedPlanId) async {
    await _sharedPlansApi.deleteSharedPlan(sharedPlanId);
    notifyListeners();
  }

  // Get a single shared plan by ID
  Future<SharedPlan?> getSharedPlanById(String sharedPlanId) async {
    return await _sharedPlansApi.getSharedPlanById(sharedPlanId);
  }

  // Fetch travel plan details by planId
  Future<Map<String, dynamic>?> fetchPlanDetails(String planId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('travelplans')
            .doc(planId)
            .get();
    return doc.data();
  }

  // Fetch recipient user details by userId
  Future<Map<String, dynamic>?> fetchRecipientDetails(String userId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('appusers')
            .doc(userId)
            .get();
    return doc.data();
  }

  // Share plan with user by username
  Future<void> sharePlanWithUsername({
    required String planId,
    required String username,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _sharedPlansApi.sharePlanWithUsername(
        planId: planId,
        ownerId: userId,
        username: username,
      );
      notifyListeners();
    } catch (e) {
      print('Error in provider sharing plan: $e');
      rethrow;
    }
  }

  Future<void> sharePlanWithUserId({
    required String planId,
    required String ownerId,
    required String sharedWithUserId,
  }) async {
    await _sharedPlansApi.sharePlanWithUserId(
      planId: planId,
      ownerId: ownerId,
      sharedWithUserId: sharedWithUserId,
    );
    notifyListeners();
  }
}
