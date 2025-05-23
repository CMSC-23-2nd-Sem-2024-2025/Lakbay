class User {
  // this is the user model
  String? id;
  String firstName;
  String lastName;
  String userName;
  String? phoneNumber;
  String email;
  List<String> interests;
  List<String> styles;
  bool public;
  

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.phoneNumber,
    required this.email,
    this.interests = const [],
    this.styles = const [],
    this.public = false,
    
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
      public: json['public'] ?? false,
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
      'public': public,
      
    };
  }
}
