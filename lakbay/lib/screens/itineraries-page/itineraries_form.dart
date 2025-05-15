import 'package:flutter/material.dart';

class ItinerariesFormPage extends StatelessWidget {
  const ItinerariesFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController itineraryNameController =
        TextEditingController();
    final TextEditingController activitiesController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController timeScheduleController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Plan Name'),
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
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
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Collect data and return
                  final itineraryData = {
                    'itineraryName': itineraryNameController.text,
                    'activities': activitiesController.text,
                    'location': locationController.text,
                    'timeSchedule': timeScheduleController.text,
                  };
                  Navigator.pop(context, itineraryData);
                },
                child: Text('Save Itinerary'),
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
