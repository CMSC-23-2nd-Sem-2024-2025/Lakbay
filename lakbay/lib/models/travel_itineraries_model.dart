class TravelItinerary {
  String? id;
  String travelPlanId;
  String itineraryName;
  List<String> activities;
  String location;
  DateTime timeSchedule;

  TravelItinerary({
    this.id,
    required this.travelPlanId,
    required this.itineraryName,
    required this.activities,
    required this.location,
    required this.timeSchedule,
  });

  factory TravelItinerary.fromJson(Map<String, dynamic> json) {
    return TravelItinerary(
      id: json['id'],
      travelPlanId: json['travelPlanId'],
      itineraryName: json['itineraryName'],
      activities: List<String>.from(json['activities'] ?? []),
      location: json['location'],
      timeSchedule:
          json['timeSchedule'] != null
              ? DateTime.parse(json['timeSchedule'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelPlanId': travelPlanId,
      'itineraryName': itineraryName,
      'activities': activities,
      'location': location,
      'timeSchedule': timeSchedule.toIso8601String(),
    };
  }
}
