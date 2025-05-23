import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/models/travel_plans_model.dart';

import 'package:lakbay/screens/travel-page/travel_add_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TravelFormPage extends StatefulWidget {
  const TravelFormPage({super.key});

  @override
  State<TravelFormPage> createState() => _TravelFormPageState();
}

class _TravelFormPageState extends State<TravelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final departureController = TextEditingController();
  final returnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    departureController.dispose();
    returnController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFF97419);

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // for back button
                

                const SizedBox(height: 16),

                // RichText is used to control the design or style of each word
                // TextSpan allows the user to select and modify the text for changing its font color, style, or size
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),

                    // title of the travel form page
                    children: [
                      TextSpan(text: 'MAKE YOUR '),
                      TextSpan(
                        text: 'TRAVEL\nPLAN ',
                        style: TextStyle(color: orange),
                      ),
                      TextSpan(text: 'AHEAD!'),
                    ],
                  ),
                ),

                const SizedBox(height: 42),

                _Label('Travel Name *'),
                _ShadowedTextField(
                  controller: nameController,
                  hintText: 'Enter Travel Name',
                  icon: Icons.flight_takeoff,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter travel name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                _Label('Location *'),
                _ShadowedTextField(
                  controller: locationController,
                  hintText: 'Enter Location',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                _Label('Departure Date *'),
                _ShadowedTextField(
                  controller: departureController,
                  hintText: 'Select Departure Date',
                  icon: Icons.date_range,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select departure date';
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFF97419),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFFF97419),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        departureController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),

                const SizedBox(height: 40),

                _Label('Return Date *'),
                _ShadowedTextField(
                  controller: returnController,
                  hintText: 'Select Return Date',
                  icon: Icons.calendar_today_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select return date';
                    }
                    // Validate that return date is after departure date
                    if (departureController.text.isNotEmpty) {
                      final departure = DateTime.parse(
                        departureController.text,
                      );
                      final returnDate = DateTime.parse(value);
                      if (returnDate.isBefore(departure)) {
                        return 'Return date must be after departure date';
                      }
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFF97419),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFFF97419),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        returnController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),

                const SizedBox(height: 90),

                // for continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_validateFields()) return;

                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      final plan = TravelPlan(
                        id: null,
                        userId: user.uid,
                        travelName: nameController.text.trim(),
                        location: locationController.text.trim(),
                        departureDate:
                            DateTime.parse(departureController.text).toLocal(),
                        returnDate:
                            DateTime.parse(returnController.text).toLocal(),
                        flightDetails: null,
                        accommodation: null,
                        notes: null,
                        emerContact: null,
                      );

                      // Add to Firestore
                      final docRef = await FirebaseFirestore.instance
                          .collection('travelplans')
                          .add({
                            ...plan.toJson(),
                            'departureDate': departureController.text,
                            'returnDate': returnController.text,
                          });

                      // Update the plan with the generated ID
                      await docRef.update({'id': docRef.id});

                      // Go to add info page, pass planId
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TravelAddInfoPage(planId: docRef.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// for custom lable widget
// reusable widget
// used for displaying name of the field ("Travel Name", "Location")
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}

// for custom shadowed text field widget
// this gives shadow effect to each text field
class _ShadowedTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const _ShadowedTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
