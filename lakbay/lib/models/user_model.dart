class User { // this is the user model
  String? id;
  String firstName;
  String lastName;
  String userName;
  String? phoneNumber;
  String email;
  List<String> interests;
  List<String> styles;
  List<UserPlan> plans; // bale kada user may list of interests, styles, and plans

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.phoneNumber,
    required this.email,
    this.interests = const [],
    this.styles = const [],
    this.plans = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      interests: List<String>.from(json['interests'] ?? []),
      styles: List<String>.from(json['styles'] ?? []),
      plans: (json['plans'] as List<dynamic>? ?? [])
          .map((planJson) => UserPlan.fromJson(planJson))
          .toList(), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'email': email,
      'interests': interests,
      'styles': styles,
      'plans': plans.map((plan) => plan.toJson()).toList(), 
    };
  }
}

class UserPlan { //user plan
  final String planName;
  final String description;

  UserPlan({
    required this.planName,
    required this.description,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) {
    return UserPlan(
      planName: json['planName'], 
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'description': description,
    };
  }
}
