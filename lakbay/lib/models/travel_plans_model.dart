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
      departureDate: DateTime.parse(
        json['departureDate'].toString().split('T')[0],
      ),
      returnDate: DateTime.parse(json['returnDate'].toString().split('T')[0]),
      flightDetails: json['flightDetails'],
      accommodation: json['accommodation'],
      notes: json['notes'],
      emerContact: json['emerContact'],
      enableNotifications: json['enableNotifications'] ?? false,
      notificationTime:
          json['notificationTime'] != null
              ? DateTime.parse(
                json['notificationTime'].toString().split('T')[0],
              )
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
      'departureDate':
          '${departureDate.year}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}',
      'returnDate':
          '${returnDate.year}-${returnDate.month.toString().padLeft(2, '0')}-${returnDate.day.toString().padLeft(2, '0')}',
      'enableNotifications': enableNotifications,
      if (id != null) 'id': id,
      if (flightDetails != null) 'flightDetails': flightDetails,
      if (accommodation != null) 'accommodation': accommodation,
      if (notes != null) 'notes': notes,
      if (emerContact != null) 'emerContact': emerContact,
      if (notificationTime != null)
        'notificationTime':
            '${notificationTime!.year}-${notificationTime!.month.toString().padLeft(2, '0')}-${notificationTime!.day.toString().padLeft(2, '0')}',
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
    print('Generated JSON map: $map');
    return map;
  }
}
