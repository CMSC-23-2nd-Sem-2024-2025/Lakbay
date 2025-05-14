import 'dart:convert';

class TravelPlan {
  String? id;
  String? travelName;
  String? location;
  DateTime? departureDate;
  DateTime? returnDate;
  String? flightDetails;
  String? accomodation;
  String? notes;
  double? emerContact;

  TravelPlan({
    this.id,
    required this.travelName,
    required this.location,
    required this.departureDate,
    required this.returnDate,
    this.flightDetails,
    this.accomodation,
    this.notes,
    this.emerContact,
  });
}
