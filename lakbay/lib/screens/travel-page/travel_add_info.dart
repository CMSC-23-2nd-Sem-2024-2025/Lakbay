import 'package:flutter/material.dart';
import 'travel_form.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lakbay/models/travel_plans_model.dart';

class TravelAddInfoPage extends StatefulWidget {
  final String planId;
  const TravelAddInfoPage({Key? key, required this.planId}) : super(key: key);

  @override
  State<TravelAddInfoPage> createState() => _TravelAddInfoPageState();
}

class _TravelAddInfoPageState extends State<TravelAddInfoPage> {
  final flightController = TextEditingController();
  final accommodationController = TextEditingController();
  final notesController = TextEditingController();
  final emergencyContactController = TextEditingController();

  @override
  void dispose() {
    flightController.dispose();
    accommodationController.dispose();
    notesController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveAdditionalInfoAndGoHome() async {
    await FirebaseFirestore.instance
        .collection('travelplans')
        .doc(widget.planId)
        .update({
          'flightDetails':
              flightController.text.isNotEmpty ? flightController.text : null,
          'accommodation':
              accommodationController.text.isNotEmpty
                  ? accommodationController.text
                  : null,
          'notes':
              notesController.text.isNotEmpty ? notesController.text : null,
          'emerContact':
              emergencyContactController.text.isNotEmpty
                  ? emergencyContactController.text
                  : null,
        });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFF97419);
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ), // icon back button
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TravelFormPage(),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: 'ENRICH YOUR '),
                    TextSpan(text: 'JOURNEY', style: TextStyle(color: orange)),
                    TextSpan(text: ' DETAILS!'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _Label('Flight Details'),
              _ShadowedTextField(
                controller: flightController,
                hintText: 'Enter flight details',
                icon: Icons.flight,
              ),
              const SizedBox(height: 24),
              _Label('Accommodation'),
              _ShadowedTextField(
                controller: accommodationController,
                hintText: 'Enter accommodation details',
                icon: Icons.hotel,
              ),
              const SizedBox(height: 24),
              _Label('Notes'),
              _ShadowedTextField(
                controller: notesController,
                hintText: 'Enter notes',
                icon: Icons.sticky_note_2_outlined,
              ),
              const SizedBox(height: 24),
              _Label('Emergency Contact?'),
              _ShadowedTextField(
                controller: emergencyContactController,
                hintText: 'Enter emergency contact',
                icon: Icons.contact_emergency,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAdditionalInfoAndGoHome,
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
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {Key? key}) : super(key: key);

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

class _ShadowedTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback? onTap;

  const _ShadowedTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onTap,
  }) : super(key: key);

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
