import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lakbay/models/shared_plans_model.dart';

class FirebaseSharedPlansApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Add a shared plan
  Future<String> addSharedPlan(SharedPlan sharedPlan) async {
    try {
      final docRef = db.collection('sharedplans').doc();
      final data = sharedPlan.toJson();
      data['id'] = docRef.id;
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      print('Error adding shared plan: $e');
      rethrow;
    }
  }

  // Get all plans shared with a user
  Stream<List<SharedPlan>> getPlansSharedWith(String userId) {
    return db
        .collection('sharedplans')
        .where('sharedWith', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SharedPlan.fromJson(doc.data(), id: doc.id))
                  .toList(),
        );
  }

  // Get all plans shared by a user
  Stream<List<SharedPlan>> getPlansSharedBy(String ownerId) {
    return db
        .collection('sharedplans')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SharedPlan.fromJson(doc.data(), id: doc.id))
                  .toList(),
        );
  }

  // Update a shared plan (e.g., to revoke or change permissions)
  Future<void> updateSharedPlan(
    String sharedPlanId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await db.collection('sharedplans').doc(sharedPlanId).update(updates);
    } catch (e) {
      print('Error updating shared plan: $e');
      rethrow;
    }
  }

  // Delete a shared plan (revoke sharing)
  Future<void> deleteSharedPlan(String sharedPlanId) async {
    try {
      await db.collection('sharedplans').doc(sharedPlanId).delete();
    } catch (e) {
      print('Error deleting shared plan: $e');
      rethrow;
    }
  }

  // Get a single shared plan by ID
  Future<SharedPlan?> getSharedPlanById(String sharedPlanId) async {
    try {
      final doc = await db.collection('sharedplans').doc(sharedPlanId).get();
      if (!doc.exists) return null;
      return SharedPlan.fromJson(doc.data()!, id: doc.id);
    } catch (e) {
      print('Error fetching shared plan: $e');
      rethrow;
    }
  }

  // Get user ID from username
  Future<String?> getUserIdFromUsername(String username) async {
    try {
      final querySnapshot =
          await db
              .collection('appusers')
              .where('userName', isEqualTo: username)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      return querySnapshot.docs.first.id;
    } catch (e) {
      print('Error looking up username: $e');
      rethrow;
    }
  }

  // Check if plan is already shared with user
  Future<bool> isPlanSharedWithUser(String planId, String userId) async {
    try {
      final querySnapshot =
          await db
              .collection('sharedplans')
              .where('planId', isEqualTo: planId)
              .where('sharedWith', isEqualTo: userId)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking shared plan: $e');
      rethrow;
    }
  }

  // Share plan with user by username
  Future<String> sharePlanWithUsername({
    required String planId,
    required String ownerId,
    required String username,
  }) async {
    try {
      // Get recipient's user ID
      final recipientId = await getUserIdFromUsername(username);
      if (recipientId == null) {
        throw Exception('User not found');
      }

      // Check if plan is already shared
      final isShared = await isPlanSharedWithUser(planId, recipientId);
      if (isShared) {
        throw Exception('Plan is already shared with this user');
      }

      // Create shared plan
      final sharedPlan = SharedPlan(
        planId: planId,
        ownerId: ownerId,
        sharedWith: recipientId,
        sharedAt: DateTime.now(),
        status: 'active',
        permissions: {'canEdit': false, 'canDelete': false},
      );

      return await addSharedPlan(sharedPlan);
    } catch (e) {
      print('Error sharing plan: $e');
      rethrow;
    }
  }

  Future<String> sharePlanWithUserId({
    required String planId,
    required String ownerId,
    required String sharedWithUserId,
  }) async {
    try {
      // Check if plan is already shared
      final isShared = await isPlanSharedWithUser(planId, sharedWithUserId);
      if (isShared) {
        throw Exception('Plan is already shared with this user');
      }

      // Create shared plan
      final sharedPlan = SharedPlan(
        planId: planId,
        ownerId: ownerId,
        sharedWith: sharedWithUserId,
        sharedAt: DateTime.now(),
        status: 'active',
        permissions: {'canEdit': false, 'canDelete': false},
      );

      return await addSharedPlan(sharedPlan);
    } catch (e) {
      print('Error sharing plan by userId: $e');
      rethrow;
    }
  }
}
