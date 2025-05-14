// import 'package:cloud_firestore/cloud_firestore.dart';

// class TravelPlan {
//   final String id;
//   final String userId;
//   final String travelName;
//   final String location;
//   final DateTime departureDate;
//   final DateTime returnDate;
//   final String? flightDetails;
//   final String? accommodation;
//   final String? notes;
//   final String? emergencyContact;

//   TravelPlan({
//     required this.id,
//     required this.userId,
//     required this.travelName,
//     required this.location,
//     required this.departureDate,
//     required this.returnDate,
//     this.flightDetails,
//     this.accommodation,
//     this.notes,
//     this.emergencyContact,
//   });

//   // Convert TravelPlan to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'travelName': travelName,
//       'location': location,
//       'departureDate': Timestamp.fromDate(departureDate),
//       'returnDate': Timestamp.fromDate(returnDate),
//       'flightDetails': flightDetails,
//       'accommodation': accommodation,
//       'notes': notes,
//       'emergencyContact': emergencyContact,
//     };
//   }

//   // Create TravelPlan from Firestore document
//   factory TravelPlan.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return TravelPlan(
//       id: doc.id,
//       userId: data['userId'] ?? '',
//       travelName: data['travelName'] ?? '',
//       location: data['location'] ?? '',
//       departureDate: (data['departureDate'] as Timestamp).toDate(),
//       returnDate: (data['returnDate'] as Timestamp).toDate(),
//       flightDetails: data['flightDetails'],
//       accommodation: data['accommodation'],
//       notes: data['notes'],
//       emergencyContact: data['emergencyContact'],
//     );
//   }

//   // Create a copy of TravelPlan with updated fields
//   TravelPlan copyWith({
//     String? userId,
//     String? travelName,
//     String? location,
//     DateTime? departureDate,
//     DateTime? returnDate,
//     String? flightDetails,
//     String? accommodation,
//     String? notes,
//     String? emergencyContact,
//   }) {
//     return TravelPlan(
//       id: id,
//       userId: userId ?? this.userId,
//       travelName: travelName ?? this.travelName,
//       location: location ?? this.location,
//       departureDate: departureDate ?? this.departureDate,
//       returnDate: returnDate ?? this.returnDate,
//       flightDetails: flightDetails ?? this.flightDetails,
//       accommodation: accommodation ?? this.accommodation,
//       notes: notes ?? this.notes,
//       emergencyContact: emergencyContact ?? this.emergencyContact,
//     );
//   }
// }
