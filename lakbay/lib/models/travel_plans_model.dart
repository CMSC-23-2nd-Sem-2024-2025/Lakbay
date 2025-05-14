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

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      travelName: json['travelName'],
      location: json['location'],
      departureDate: json['departureDate'],
      returnDate: json['returnDate'],
      flightDetails: json['flightDetails'],
      accomodation: json['accomodation'],
      notes: json['notes'],
      emerContact: json['emerContact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelName': travelName,
      'location': location,
      'departureDate': departureDate,
      'returnDate': returnDate,
    };
  }
}
