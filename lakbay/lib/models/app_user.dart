// import 'package:cloud_firestore/cloud_firestore.dart';

// class AppUser {
//   final String id;
//   final String firstName;
//   final String lastName;
//   final String username;
//   final String email;
//   final String? profileImage;
//   final List<String> interests;
//   final List<String> travelStyles;

//   AppUser({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.username,
//     required this.email,
//     this.profileImage,
//     required this.interests,
//     required this.travelStyles,
//   });

//   // Convert AppUser to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName,
//       'username': username,
//       'email': email,
//       'profileImage': profileImage,
//       'interests': interests,
//       'travelStyles': travelStyles,
//     };
//   }

//   // Create AppUser from Firestore document
//   factory AppUser.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return AppUser(
//       id: doc.id,
//       firstName: data['firstName'] ?? '',
//       lastName: data['lastName'] ?? '',
//       username: data['username'] ?? '',
//       email: data['email'] ?? '',
//       profileImage: data['profileImage'],
//       interests: List<String>.from(data['interests'] ?? []),
//       travelStyles: List<String>.from(data['travelStyles'] ?? []),
//     );
//   }

//   // Create a copy of AppUser with updated fields
//   AppUser copyWith({
//     String? firstName,
//     String? lastName,
//     String? username,
//     String? email,
//     String? profileImage,
//     List<String>? interests,
//     List<String>? travelStyles,
//   }) {
//     return AppUser(
//       id: id,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       username: username ?? this.username,
//       email: email ?? this.email,
//       profileImage: profileImage ?? this.profileImage,
//       interests: interests ?? this.interests,
//       travelStyles: travelStyles ?? this.travelStyles,
//     );
//   }
// }
