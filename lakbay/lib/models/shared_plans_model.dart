import 'package:cloud_firestore/cloud_firestore.dart';

// shared plan model
class SharedPlan {
  final String? id;
  final String planId;
  final String ownerId;
  final String sharedWith;
  final DateTime sharedAt;
  final String status;
  final Map<String, bool>? permissions;

  SharedPlan({
    this.id,
    required this.planId,
    required this.ownerId,
    required this.sharedWith,
    required this.sharedAt,
    required this.status,
    this.permissions,
  });

  factory SharedPlan.fromJson(Map<String, dynamic> json, {String? id}) {
    return SharedPlan(
      id: id ?? json['id'],
      planId: json['planId'] as String,
      ownerId: json['ownerId'] as String,
      sharedWith: json['sharedWith'] as String,
      sharedAt:
          (json['sharedAt'] is DateTime)
              ? json['sharedAt']
              : (json['sharedAt'] != null && json['sharedAt'] is Timestamp)
              ? (json['sharedAt'] as Timestamp).toDate()
              : DateTime.now(),
      status: json['status'] as String,
      permissions:
          (json['permissions'] != null)
              ? Map<String, bool>.from(json['permissions'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'sharedAt': sharedAt,
      'status': status,
      if (permissions != null) 'permissions': permissions,
    };
  }
}
