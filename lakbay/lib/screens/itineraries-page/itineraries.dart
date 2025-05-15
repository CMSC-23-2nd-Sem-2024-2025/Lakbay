import 'package:flutter/material.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries_form.dart';

class ItinerariesPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const ItinerariesPage({super.key, required this.plan});

  @override
  _ItinerariesPageState createState() => _ItinerariesPageState();
}

class _ItinerariesPageState extends State<ItinerariesPage> {
  List<Map<String, String>> itineraries = [];

  void _addItinerary(Map<String, String> itinerary) {
    setState(() {
      itineraries.add(itinerary);
    });
  }

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
              "User's Travel Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Name: ${widget.plan['travelName'] ?? 'No Name'}',
                  ),
                  Text('Location: ${widget.plan['location'] ?? 'No Location'}'),
                  Text(
                    'Departure Time: ${widget.plan['departureDate'] ?? 'No Date'}',
                  ),
                  Text(
                    'Return Date: ${widget.plan['returnDate'] ?? 'No Date'}',
                  ),
                  Text(
                    'Flight Details: ${widget.plan['flightDetails'] ?? 'No Flight details'}',
                  ),
                  Text(
                    'Accommodation: ${widget.plan['accommodation'] ?? 'No Accommodation details'}',
                  ),
                  Text(
                    'Notes: ${widget.plan['notes'] ?? 'User do not have notes'}',
                  ),
                  Text(
                    'Emergency Contact: ${widget.plan['emerContact'] ?? 'No Emergency contact'}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your Itineraries',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: itineraries.length,
                itemBuilder: (context, index) {
                  final itinerary = itineraries[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(itinerary['itineraryName'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activities: ${itinerary['activities'] ?? 'No Activities'}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newItinerary = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItinerariesFormPage(),
                    ),
                  );
                  if (newItinerary != null) {
                    _addItinerary(newItinerary);
                  }
                },
                child: Text(
                  'Add Itinerary',
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
