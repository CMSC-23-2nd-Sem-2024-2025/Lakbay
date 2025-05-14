// import 'package:cloud_firestore/cloud_firestore.dart';

// class Itinerary {
//   final String id;
//   final String travelPlanId;
//   final String itineraryName;
//   final List<String> activities;
//   final String location;
//   final DateTime timeSchedule;

//   Itinerary({
//     required this.id,
//     required this.travelPlanId,
//     required this.itineraryName,
//     required this.activities,
//     required this.location,
//     required this.timeSchedule,
//   });

//   // Convert Itinerary to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'travelPlanId': travelPlanId,
//       'itineraryName': itineraryName,
//       'activities': activities,
//       'location': location,
//       'timeSchedule': Timestamp.fromDate(timeSchedule),
//     };
//   }

//   // Create Itinerary from Firestore document
//   factory Itinerary.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Itinerary(
//       id: doc.id,
//       travelPlanId: data['travelPlanId'] ?? '',
//       itineraryName: data['itineraryName'] ?? '',
//       activities: List<String>.from(data['activities'] ?? []),
//       location: data['location'] ?? '',
//       timeSchedule: (data['timeSchedule'] as Timestamp).toDate(),
//     );
//   }

//   // Create a copy of Itinerary with updated fields
//   Itinerary copyWith({
//     String? travelPlanId,
//     String? itineraryName,
//     List<String>? activities,
//     String? location,
//     DateTime? timeSchedule,
//   }) {
//     return Itinerary(
//       id: id,
//       travelPlanId: travelPlanId ?? this.travelPlanId,
//       itineraryName: itineraryName ?? this.itineraryName,
//       activities: activities ?? this.activities,
//       location: location ?? this.location,
//       timeSchedule: timeSchedule ?? this.timeSchedule,
//     );
//   }
// }
