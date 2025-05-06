import 'dart:convert';

class UserExpense {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? password;

  UserExpense({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  factory UserExpense.fromJson(Map<String, dynamic> json) {
    return UserExpense(
      id: json['id'],
      firstName: json['firstName'] ?? 'No first name',
      lastName: json['lastName'] ?? 'No last name',
      email: json['email'] ?? 'No email',
      password: json['password'] ?? 'No password',
    );
  }

  static List<UserExpense> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data
        .map<UserExpense>((dynamic d) => UserExpense.fromJson(d))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName ?? 'No first name',
      'lastName': lastName ?? 'No last name',
      'email': email ?? 'No email ',
      // 'password': password ?? 'No password', // passwordd should not be included in firebas
    };
  }
}

// used to enumarate constant categories
enum FoodCategory {
  bills,
  transportation,
  food,
  utilities,
  health,
  entertainment,
  miscellaneous,
}

// fields required in the firebase
class Expenses {
  String? id;
  String? name;
  String? description;
  double? amount;
  bool? paid;
  final FoodCategory category;

  // constructor
  Expenses({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.amount,
    required this.paid,
  });

  // Factory constructor to instantiate object from json format
  // yung data na nasa firestore is stored in a json format
  // kapag magfefetch, naka json format
  // kapag gusto nating ng sariling object, then convert this map into todo object
  // gagawin lang into todo object yung document
  factory Expenses.fromJson(Map<String, dynamic> json) {
    return Expenses(
      id: json['id'],
      name: json['name'] ?? 'No name',
      description: json['description'] ?? 'No description',

      // firstWhere method matches the string (food, bills, etc.) from the FoodCategory enum value made by the user
      category: FoodCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => FoodCategory.miscellaneous,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paid: json['paid'] ?? false, // Convert to double
    );
  }

  static List<Expenses> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<Expenses>((dynamic d) => Expenses.fromJson(d)).toList();
  }

  // this returns a map --kabaliktaran lang
  // from todo object this will make in map in json format
  // lalo na kapag mag-aadd tayo ng data, then store sa firestore
  // need natin i-convert into map before we store it in firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name ?? 'No name',
      'description': description ?? 'No description',
      'amount': amount ?? 0.0,
      'paid': paid ?? false, // Correct field name
      'category': category.toString().split('.').last,
    };
  }
}
