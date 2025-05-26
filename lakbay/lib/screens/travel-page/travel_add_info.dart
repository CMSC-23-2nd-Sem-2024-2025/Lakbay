import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lakbay/components/scaffolds.dart';
import 'package:lakbay/models/travel_plans_model.dart';
import 'package:lakbay/providers/plan_provider.dart';
import 'package:provider/provider.dart';

class TravelAddInfoPage extends StatefulWidget {
  final TravelPlan travelPlan;
  const TravelAddInfoPage({super.key, required this.travelPlan});

  @override
  State<TravelAddInfoPage> createState() => _TravelAddInfoPageState();
}

class _TravelAddInfoPageState extends State<TravelAddInfoPage> {
  @override
  void initState() {
    super.initState();
    print('TravelAddInfoPage initialized with plan:'); // Debug print
    print('Travel Name: ${widget.travelPlan.travelName}'); // Debug print
    print('Location: ${widget.travelPlan.location}'); // Debug print
    print('Image URL: ${widget.travelPlan.imageUrl}'); // Debug print
  }

  // add the controllers for the text fields
  final flightController = TextEditingController();
  final accommodationController = TextEditingController();
  final notesController = TextEditingController();
  final emergencyContactController = TextEditingController();

  @override
  //dispose the controllers once done
  void dispose() {
    flightController.dispose();
    accommodationController.dispose();
    notesController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  // save info function
  Future<void> _saveAdditionalInfoAndGoHome() async {
    try {
      print('Starting to save additional info...');
      print('Original plan image URL: ${widget.travelPlan.imageUrl}');
      print('Original plan ID: ${widget.travelPlan.id}');
      print('Original plan userId: ${widget.travelPlan.userId}');

      // Create the updated plan with the original data
      final updatedPlan = TravelPlan(
        id: widget.travelPlan.id,
        userId: widget.travelPlan.userId,
        travelName: widget.travelPlan.travelName,
        location: widget.travelPlan.location,
        departureDate: widget.travelPlan.departureDate,
        returnDate: widget.travelPlan.returnDate,
        // Only add optional fields if they have content
        flightDetails:
            flightController.text.trim().isNotEmpty
                ? flightController.text.trim()
                : null,
        accommodation:
            accommodationController.text.trim().isNotEmpty
                ? accommodationController.text.trim()
                : null,
        notes:
            notesController.text.trim().isNotEmpty
                ? notesController.text.trim()
                : null,
        emerContact:
            emergencyContactController.text.trim().isNotEmpty
                ? emergencyContactController.text.trim()
                : null,
        enableNotifications: widget.travelPlan.enableNotifications,
        notificationTime: widget.travelPlan.notificationTime,
        imageUrl: widget.travelPlan.imageUrl,
      );

      print('Updated plan created with data:');
      print('Travel Name: ${updatedPlan.travelName}');
      print('Location: ${updatedPlan.location}');
      print('Image URL: ${updatedPlan.imageUrl}');
      print('User ID: ${updatedPlan.userId}');
      print('Flight Details: ${updatedPlan.flightDetails}');
      print('Accommodation: ${updatedPlan.accommodation}');
      print('Notes: ${updatedPlan.notes}');
      print('Emergency Contact: ${updatedPlan.emerContact}');

      print('Getting PlanProvider...');
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      print('PlanProvider obtained, adding plan...');

      // Add the plan using the provider
      await planProvider.addPlan(updatedPlan);
      print('Plan added successfully');

      if (!mounted) {
        print('Widget is not mounted, cannot navigate');
        return;
      }

      print('Setting navigation index to 0...');
      // Set the navigation index to 0 (home page)
      MainScaffold.navIndexNotifier.value = 0;

      print('Navigating to MainScaffold...');
      // Navigate to main scaffold and remove all previous routes
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScaffold()),
        (route) => false,
      );
      print('Navigation completed');
    } catch (e, stackTrace) {
      print('Error in _saveAdditionalInfoAndGoHome: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    onPressed: () async {
                      print('Skip button pressed');
                      try {
                        // Create plan with null values for optional fields
                        final updatedPlan = TravelPlan(
                          id: widget.travelPlan.id,
                          userId: widget.travelPlan.userId,
                          travelName: widget.travelPlan.travelName,
                          location: widget.travelPlan.location,
                          departureDate: widget.travelPlan.departureDate,
                          returnDate: widget.travelPlan.returnDate,
                          flightDetails: null,
                          accommodation: null,
                          notes: null,
                          emerContact: null,
                          enableNotifications:
                              widget.travelPlan.enableNotifications,
                          notificationTime: widget.travelPlan.notificationTime,
                          imageUrl: widget.travelPlan.imageUrl,
                        );

                        print('Saving plan with skipped fields:');
                        print('Travel Name: ${updatedPlan.travelName}');
                        print('Location: ${updatedPlan.location}');
                        print('Image URL: ${updatedPlan.imageUrl}');
                        print('User ID: ${updatedPlan.userId}');

                        final planProvider = Provider.of<PlanProvider>(
                          context,
                          listen: false,
                        );
                        await planProvider.addPlan(updatedPlan);
                        print('Plan saved successfully with skipped fields');

                        if (!mounted) return;

                        // Set the navigation index to 0 (home page)
                        MainScaffold.navIndexNotifier.value = 0;

                        // Navigate to main scaffold and remove all previous routes
                        await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => MainScaffold(),
                          ),
                          (route) => false,
                        );
                        print('Navigation completed after skip');
                      } catch (e, stackTrace) {
                        print('Error in skip button: $e');
                        print('Stack trace: $stackTrace');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving plan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
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
              const SizedBox(height: 40),
              _Label('Accommodation'),
              _ShadowedTextField(
                controller: accommodationController,
                hintText: 'Enter accommodation details',
                icon: Icons.hotel,
              ),
              const SizedBox(height: 40),
              _Label('Notes'),
              _ShadowedTextField(
                controller: notesController,
                hintText: 'Enter notes',
                icon: Icons.sticky_note_2_outlined,
              ),
              const SizedBox(height: 40),
              _Label('Emergency Contact?'),
              _ShadowedTextField(
                controller: emergencyContactController,
                hintText: 'Enter emergency contact',
                icon: Icons.contact_emergency,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 90),
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
  const _Label(this.text);

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
  final TextInputType? keyboardType;

  const _ShadowedTextField({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onTap,
    this.keyboardType,
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
        keyboardType: keyboardType,
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
