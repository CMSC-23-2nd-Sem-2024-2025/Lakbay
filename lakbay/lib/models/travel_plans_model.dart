class TravelPlan {
  String? id;
  String userId;
  String? travelName;
  String? location;
  DateTime? departureDate;
  DateTime? returnDate;
  String? flightDetails;
  String? accommodation;
  String? notes;
  String? emerContact;

  TravelPlan({
    this.id,
    required this.userId,
    required this.travelName,
    required this.location,
    required this.departureDate,
    required this.returnDate,
    this.flightDetails,
    this.accommodation,
    this.notes,
    this.emerContact,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      userId: json['userId'],
      travelName: json['travelName'],
      location: json['location'],
      departureDate:
          // parses the date from json format to datetime
          json['departureDate'] != null
              ? DateTime.parse(json['departureDate'])
              : null,
      returnDate:
          json['returnDate'] != null
              ? DateTime.parse(json['returnDate'])
              : null,
      flightDetails: json['flightDetails'],
      accommodation: json['accommodation'],
      notes: json['notes'],
      emerContact: json['emerContact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'travelName': travelName,
      'location': location,
      'departureDate':
          departureDate
              ?.toIso8601String(), // method that stores the date in iso8601
      // format then parsed into string
      'returnDate': returnDate?.toIso8601String(),
      'flightDetails': flightDetails,
      'accommodation': accommodation,
      'notes': notes,
      'emerContact': emerContact,
    };
  }
}
