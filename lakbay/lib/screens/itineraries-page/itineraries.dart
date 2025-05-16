import 'package:flutter/material.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItinerariesPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const ItinerariesPage({super.key, required this.plan});

  @override
  _ItinerariesPageState createState() => _ItinerariesPageState();
}

class _ItinerariesPageState extends State<ItinerariesPage> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('User not authenticated')),
      );
    }

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
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No itineraries yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  final itineraries =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        // Convert all values to String (or empty string if null)
                        return data.map(
                          (key, value) =>
                              MapEntry(key, value?.toString() ?? ''),
                        );
                      }).toList();

                  return ListView.builder(
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      final itinerary = itineraries[index];
                      return GestureDetector(
                        onTap: () async {
                          final updatedItinerary = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ItinerariesFormPage(
                                    existingItinerary: itinerary,
                                    travelPlanId: widget.plan['id'].toString(),
                                  ),
                            ),
                          );
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
                              builder:
                                  (context) => ItinerariesFormPage(
                                    travelPlanId: widget.plan['id'].toString(),
                                  ),
                            ),
                          );
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
