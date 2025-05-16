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
  @override
  void initState() {
    super.initState();

    locationController.addListener(() {
      setState(() {});
    });
  }

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final departureController = TextEditingController();
  final returnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),

                const SizedBox(height: 40),

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

                _Label('Travel Name'),
                _ShadowedTextField(
                  controller: nameController,
                  hintText: 'Enter Travel Name',
                  icon: Icons.flight_takeoff,
                ),

                const SizedBox(height: 40),

                _Label('Location'),
                _ShadowedTextField(
                  controller: locationController,
                  hintText: 'Enter Location',
                  icon: Icons.location_on_outlined,
                ),

                // SizedBox(height: 200, child: ListView.builder(
                //   itemCount: 5,
                //   itemBuilder: (context, index){
                //     return GestureDetector(
                //       onTap: (){

                //       },

                //       child: Text("Location $index"),

                //     );
                //   }

                //   )),
                const SizedBox(height: 40),

                _Label('Departure Date'),
                _ShadowedTextField(
                  controller: departureController,
                  hintText: 'Select Departure Date',
                  icon: Icons.date_range,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      // mode: DateTimeFieldPickerMode.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(
                                0xFFF97419,
                              ), // orange header & selection
                              onPrimary: Colors.white, // text on primary color
                              onSurface: Colors.black, // default text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(
                                  0xFFF97419,
                                ), // button text color
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

                _Label('Return Date'),
                _ShadowedTextField(
                  controller: returnController,
                  hintText: 'Select Return Date',
                  icon: Icons.calendar_today_outlined,
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
                      if (_formKey.currentState!.validate()) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final plan = TravelPlan(
                          id: null,
                          userId: user.uid,
                          travelName: nameController.text.trim(),
                          location: locationController.text.trim(),
                          departureDate:
                              DateTime.parse(
                                departureController.text,
                              ).toLocal(),
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
                              // Store only the date part as a string (YYYY-MM-DD)
                              'departureDate':
                                  departureController.text.isNotEmpty
                                      ? departureController.text
                                      : null,
                              'returnDate':
                                  returnController.text.isNotEmpty
                                      ? returnController.text
                                      : null,
                            });

                        // Update the plan with the generated ID
                        await docRef.update({'id': docRef.id});

                        // Go to add info page, pass planId
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TravelAddInfoPage(planId: docRef.id),
                          ),
                        );
                      }
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

  const _ShadowedTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onTap,
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
        readOnly: onTap != null, // Make it read-only if onTap is provided
        onTap: onTap,
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
