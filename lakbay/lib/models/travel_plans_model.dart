// this is the model for travel plans. some information can be optional.

class TravelPlan {
  String? id;
  String userId;
  String travelName;
  String location;
  DateTime departureDate;
  DateTime returnDate;
  String? flightDetails;
  String? accommodation;
  String? notes;
  String? emerContact;
  bool enableNotifications;
  DateTime? notificationTime;
  String? imageUrl;

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
    this.enableNotifications = false,
    this.notificationTime,
    this.imageUrl,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      userId: json['userId'],
      travelName: json['travelName'],
      location: json['location'],
      departureDate: DateTime.parse(json['departureDate']),
      returnDate: DateTime.parse(json['returnDate']),
      flightDetails: json['flightDetails'],
      accommodation: json['accommodation'],
      notes: json['notes'],
      emerContact: json['emerContact'],
      enableNotifications: json['enableNotifications'] ?? false,
      notificationTime:
          json['notificationTime'] != null
              ? DateTime.parse(json['notificationTime'])
              : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    print('Converting TravelPlan to JSON');
    final map = {
      'userId': userId,
      'travelName': travelName,
      'location': location,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'enableNotifications': enableNotifications,
      if (id != null) 'id': id,
      if (flightDetails != null) 'flightDetails': flightDetails,
      if (accommodation != null) 'accommodation': accommodation,
      if (notes != null) 'notes': notes,
      if (emerContact != null) 'emerContact': emerContact,
      if (notificationTime != null)
        'notificationTime': notificationTime!.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
    print('Generated JSON map: $map');
    return map;
  }
}
