import 'package:flutter/material.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries_form.dart';

class ItinerariesPage extends StatelessWidget {
  final Map<String, dynamic> plan;

  ItinerariesPage({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Itineraries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['travelName'] ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Location: ${plan['location'] ?? 'No Location'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Departure Date: ${plan['departureDate'] ?? 'No Date'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Return Date: ${plan['returnDate'] ?? 'No Date'}',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 8),
            Text(
              'Flight Details: ${plan['flightDetails'] ?? 'No Flight details'}',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 8),

            Text(
              'Accommodation: ${plan['accommodation'] ?? 'No Accommodation details'}',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 8),

            Text(
              'Notes: ${plan['notes'] ?? 'User do not have notes'}',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 8),

            Text(
              'Emergency Contact: ${plan['emerContact'] ?? 'No Emergency contact'}',
              style: TextStyle(fontSize: 16),
            ),

            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItinerariesFormPage(),
                    ),
                  );
                },
                child: Text('Add Itinerary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
