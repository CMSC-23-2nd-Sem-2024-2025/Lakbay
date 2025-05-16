import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerariesFormPage extends StatelessWidget {
  final Map<String, String>? existingItinerary;
  final String travelPlanId;

  const ItinerariesFormPage({
    super.key,
    this.existingItinerary,
    required this.travelPlanId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController itineraryNameController = TextEditingController(
      text: existingItinerary?['itineraryName'] ?? '',
    );
    final TextEditingController activitiesController = TextEditingController(
      text: existingItinerary?['activities'] ?? '',
    );
    final TextEditingController locationController = TextEditingController(
      text: existingItinerary?['location'] ?? '',
    );
    final TextEditingController timeScheduleController = TextEditingController(
      text: existingItinerary?['timeSchedule'] ?? '',
    );

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final now = DateTime.now();
        final formattedTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        ).toLocal().toString().split(' ')[1].substring(0, 5);
        timeScheduleController.text = formattedTime;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingItinerary == null ? 'New Itinerary' : 'Edit Itinerary',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: itineraryNameController,
              decoration: InputDecoration(labelText: 'Itinerary Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: activitiesController,
              decoration: InputDecoration(labelText: 'Activities'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: timeScheduleController,
              decoration: InputDecoration(labelText: 'Time Schedule'),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  print('Save Itinerary button pressed');
                  final itineraryData = {
                    'itineraryName': itineraryNameController.text,
                    'activities': activitiesController.text,
                    'location': locationController.text,
                    'timeSchedule': timeScheduleController.text,
                    'travelPlanId': travelPlanId,
                  };
                  if (existingItinerary != null &&
                      existingItinerary!['id'] != null) {
                    print(
                      'Updating existing itinerary with ID: ${existingItinerary!['id']}',
                    );
                    await FirebaseFirestore.instance
                        .collection('itineraries')
                        .doc(existingItinerary!['id'])
                        .update(itineraryData);
                    itineraryData['id'] = existingItinerary!['id']!;
                  } else {
                    print('Adding new itinerary');
                    final docRef = await FirebaseFirestore.instance
                        .collection('itineraries')
                        .add(itineraryData);
                    itineraryData['id'] = docRef.id;
                  }
                  Navigator.pop(context, itineraryData);
                },
                child: Text(
                  existingItinerary == null
                      ? 'Save Itinerary'
                      : 'Update Itinerary',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF97419),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
