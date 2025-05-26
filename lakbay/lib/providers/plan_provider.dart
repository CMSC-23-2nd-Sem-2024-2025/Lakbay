import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/api/firebase_plan_api.dart';
import 'package:lakbay/models/travel_plans_model.dart';
import 'package:lakbay/services/notification_service.dart';

class PlanProvider with ChangeNotifier {
  Stream<QuerySnapshot>? _planStream;
  final NotificationService _notificationService = NotificationService();

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

  Future<void> _scheduleNotification(TravelPlan plan) async {
    // Ensure the notification time is in the future
    final now = DateTime.now();
    DateTime scheduledTime = plan.notificationTime!;

    if (scheduledTime.isBefore(now)) {
      scheduledTime = now.add(Duration(minutes: 5));
    }

    // Calculate time until notification
    final timeUntilNotification = scheduledTime.difference(now);

    await _notificationService.scheduleTravelNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode.abs(),
      title: 'Upcoming Trip: ${plan.travelName}',
      body: 'Your trip to ${plan.location} is starting soon!',
      scheduledDate: scheduledTime,
    );

    // Verify the notification was scheduled
    final pendingNotifications =
        await _notificationService.getPendingNotifications();
    if (pendingNotifications.isNotEmpty) {}
  }

  // this is the function for adding a new travel plan. makes a new instance of the travel plan (via the model)
  // and then calls the addEntry functio from the firebase user api to interact with the firebase

  Future<void> addPlan(TravelPlan plan) async {
    try {
      print('PlanProvider: Starting addPlan');
      print('PlanProvider: Plan details:');
      print('- ID: ${plan.id}');
      print('- User ID: ${plan.userId}');
      print('- Travel Name: ${plan.travelName}');
      print('- Image URL: ${plan.imageUrl}');

      if (plan.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final planMap = plan.toJson();
      print('PlanProvider: Plan map before removing id: $planMap');

      // Only remove id if it exists
      if (planMap.containsKey('id')) {
        planMap.remove('id');
      }
      print('PlanProvider: Plan map after removing id: $planMap');

      // Add the plan using await. Once done, notify the listeners to update the UI
      final result = await firebaseService.addEntry(planMap);
      print('PlanProvider: Add entry result: $result');

      // Get the document ID from the planMap (it was added by addEntry)
      final docId = planMap['id'];
      if (docId == null) {
        throw Exception('Document ID not found in plan map');
      }

      // Create a new plan with the ID
      final planWithId = TravelPlan(
        id: docId,
        userId: plan.userId,
        travelName: plan.travelName,
        location: plan.location,
        departureDate: plan.departureDate,
        returnDate: plan.returnDate,
        flightDetails: plan.flightDetails,
        accommodation: plan.accommodation,
        notes: plan.notes,
        emerContact: plan.emerContact,
        enableNotifications: plan.enableNotifications,
        notificationTime: plan.notificationTime,
        imageUrl: plan.imageUrl,
      );
      print('PlanProvider: Created plan with ID: $docId');

      // Schedule notification if enabled
      if (plan.enableNotifications && plan.notificationTime != null) {
        await _scheduleNotification(planWithId);
      }

      notifyListeners();
      print('PlanProvider: Plan added successfully and listeners notified');
    } catch (e, stackTrace) {
      print('PlanProvider: Error in addPlan: $e');
      print('PlanProvider: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // funciton for edit. still not functional
  Future<void> editPlan(String id, TravelPlan updatedPlan) async {
    Map<String, dynamic> updatedData = updatedPlan.toJson();
    updatedData.remove('id'); // avoid updating the id field

    String message = await firebaseService.updateEntry(id, updatedData);

    // Cancel existing notification and schedule new one if enabled
    await _notificationService.cancelNotification(id.hashCode);
    await _scheduleNotification(updatedPlan);

    notifyListeners();
  }

  // function for deleting a plan.

  Future<void> deletePlan(String id) async {
    // Cancel any existing notification
    await _notificationService.cancelNotification(id.hashCode);

    // Call the deleteEntry in the user api and delete in the firebase
    String message = await firebaseService.deleteEntry(id);

    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> streamSimilarUsers({
    required String currentUserId,
    required List<String> interests,
    required List<String> styles,
  }) {
    // Listen to all users and filter in Dart
    return FirebaseFirestore.instance.collection('appusers').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) {
            // Only include users with public == true
            if (user['public'] != true) return false;
            final userInterests = List<String>.from(user['interests'] ?? []);
            final userStyles = List<String>.from(user['styles'] ?? []);
            final hasMatchingInterest = interests.any(userInterests.contains);
            final hasMatchingStyle = styles.any(userStyles.contains);
            return hasMatchingInterest || hasMatchingStyle;
          })
          .toList();
    });
  }
}
