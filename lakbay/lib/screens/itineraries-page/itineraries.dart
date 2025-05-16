import 'package:flutter/material.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItinerariesPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const ItinerariesPage({super.key, required this.plan});

  @override
  _ItinerariesPageState createState() => _ItinerariesPageState();
}

class _ItinerariesPageState extends State<ItinerariesPage> {
  bool _isAdding = false;

  void _addItinerary(Map<String, String> itinerary) async {
    if (_isAdding) return; // Prevent multiple submissions
    setState(() {
      _isAdding = true;
    });

    print('Adding itinerary: ${itinerary['itineraryName']}');
    final docRef = await FirebaseFirestore.instance
        .collection('itineraries')
        .add(itinerary);
    itinerary['id'] = docRef.id;
    print('Itinerary added with ID: ${docRef.id}');
    setState(() {
      _isAdding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itineraries'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
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
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('itineraries')
                        .where('travelPlanId', isEqualTo: widget.plan['id'])
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading itineraries'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(child: Text('No itineraries yet.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final itinerary = Map<String, String>.from(data);
                      itinerary['id'] = docs[index].id;
                      return GestureDetector(
                        onTap: () async {
                          final updatedItinerary = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ItinerariesFormPage(
                                    existingItinerary: itinerary,
                                  ),
                            ),
                          );
                          // Optionally, handle update logic here if needed
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              itinerary['itineraryName'] ?? 'No Name',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Activities: ${itinerary['activities'] ?? 'No Activities'}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isAdding
                        ? null
                        : () async {
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
