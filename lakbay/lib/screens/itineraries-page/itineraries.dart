import 'package:flutter/material.dart';
import 'package:lakbay/screens/itineraries-page/itineraries_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/components/scaffolds.dart';

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
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'Itineraries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Color(0xFFF97419),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            MainScaffold.navIndexNotifier.value = 0;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MainScaffold()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Travel Plan Section
              Text(
                "Travel Plan Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      Icons.flight_takeoff,
                      'Travel Name',
                      widget.plan['travelName'] ?? 'No Name',
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on,
                      'Location',
                      widget.plan['location'] ?? 'No Location',
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Departure',
                      _formatDate(widget.plan['departureDate']),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_month,
                      'Return',
                      _formatDate(widget.plan['returnDate']),
                    ),
                    if (widget.plan['flightDetails'] != null) ...[
                      SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.flight,
                        'Flight Details',
                        widget.plan['flightDetails'],
                      ),
                    ],
                    if (widget.plan['accommodation'] != null) ...[
                      SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.hotel,
                        'Accommodation',
                        widget.plan['accommodation'],
                      ),
                    ],
                    if (widget.plan['notes'] != null) ...[
                      SizedBox(height: 16),
                      _buildInfoRow(Icons.note, 'Notes', widget.plan['notes']),
                    ],
                    if (widget.plan['emerContact'] != null) ...[
                      SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.emergency,
                        'Emergency Contact',
                        widget.plan['emerContact'],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Itineraries Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Itineraries',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed:
                        _isAdding
                            ? null
                            : () async {
                              final newItinerary = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ItinerariesFormPage(
                                        travelPlanId:
                                            widget.plan['id'].toString(),
                                      ),
                                ),
                              );
                            },
                    icon: Icon(Icons.add, color: Colors.white, size: 20),
                    label: Text(
                      'Add Itinerary',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF97419),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size(0, 40),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('itineraries')
                        .where('travelPlanId', isEqualTo: widget.plan['id'])
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No itineraries yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first itinerary to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final itineraries =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return data.map(
                          (key, value) =>
                              MapEntry(key, value?.toString() ?? ''),
                        );
                      }).toList();

                  return Column(
                    children:
                        itineraries.map((itinerary) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final updatedItinerary = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ItinerariesFormPage(
                                            existingItinerary: itinerary,
                                            travelPlanId:
                                                widget.plan['id'].toString(),
                                          ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              itinerary['itineraryName'] ??
                                                  'No Name',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                final confirm = await showDialog<
                                                  bool
                                                >(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: Text(
                                                          'Delete Itinerary',
                                                        ),
                                                        content: Text(
                                                          'Are you sure you want to delete this itinerary?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                            child: Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                            child: Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );

                                                if (confirm == true) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('itineraries')
                                                      .doc(itinerary['id'])
                                                      .delete();
                                                }
                                              },
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red[400],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFFF97419),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            _formatTime(
                                                  itinerary['startTime'] ?? '',
                                                ) +
                                                ' - ' +
                                                _formatTime(
                                                  itinerary['endTime'] ?? '',
                                                ),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Color(0xFFF97419),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              itinerary['location'] ??
                                                  'No Location',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_note,
                                            size: 16,
                                            color: Color(0xFFF97419),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              itinerary['activities'] ??
                                                  'No Activities',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Color(0xFFF97419)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'No Date';
    if (dateValue is Timestamp) {
      final date = dateValue.toDate();
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    }
    try {
      final date = DateTime.parse(dateValue.toString());
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (_) {
      return dateValue.toString();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatTime(String time) {
    if (time.isEmpty) return 'No Time';
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }
}
