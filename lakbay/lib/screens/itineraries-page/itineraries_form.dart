import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class ItinerariesFormPage extends StatefulWidget {
  final Map<String, String>? existingItinerary;
  final String travelPlanId;

  const ItinerariesFormPage({
    super.key,
    this.existingItinerary,
    required this.travelPlanId,
  });

  @override
  State<ItinerariesFormPage> createState() => _ItinerariesFormPageState();
}

class _ItinerariesFormPageState extends State<ItinerariesFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController itineraryNameController;
  late TextEditingController activitiesController;
  late TextEditingController locationController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  LatLong? selectedLocation;

  @override
  void initState() {
    super.initState();
    itineraryNameController = TextEditingController(
      text: widget.existingItinerary?['itineraryName'] ?? '',
    );
    activitiesController = TextEditingController(
      text: widget.existingItinerary?['activities'] ?? '',
    );
    locationController = TextEditingController(
      text: widget.existingItinerary?['location'] ?? '',
    );
    startTimeController = TextEditingController(
      text: widget.existingItinerary?['startTime'] ?? '',
    );
    endTimeController = TextEditingController(
      text: widget.existingItinerary?['endTime'] ?? '',
    );
    locationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    itineraryNameController.dispose();
    activitiesController.dispose();
    locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF97419),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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

      setState(() {
        if (isStartTime) {
          startTimeController.text = formattedTime;
        } else {
          endTimeController.text = formattedTime;
        }
      });
    }
  }

  Future<void> _showLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('Pick Location'),
                backgroundColor: Color(0xFFF97419),
              ),
              body: FlutterLocationPicker(
                initPosition: LatLong(14.1657, 121.2417),
                onPicked: (pickedData) {
                  setState(() {
                    selectedLocation = pickedData.latLong;
                    locationController.text =
                        pickedData.address ?? 'Selected Location';
                  });
                  Navigator.pop(context);
                },
                searchBarHintText: 'Search location...',
                selectLocationButtonText: 'Select Location',
                selectLocationButtonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFF97419)),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                showSearchBar: true,
                markerIcon: Icon(
                  Icons.location_on,
                  color: Color(0xFFF97419),
                  size: 40,
                ),
              ),
            ),
      ),
    );
  }

  bool _validateFields() {
    if (itineraryNameController.text.isEmpty ||
        activitiesController.text.isEmpty ||
        locationController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingItinerary == null ? 'New Itinerary' : 'Edit Itinerary',
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: itineraryNameController,
                decoration: InputDecoration(
                  labelText: 'Itinerary Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter itinerary name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: activitiesController,
                decoration: InputDecoration(
                  labelText: 'Activities *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter activities';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
                readOnly: true,
                onTap: _showLocationPicker,
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Schedule *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Time *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        startTimeController.text.isEmpty
                                            ? 'Select time'
                                            : startTimeController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              startTimeController.text.isEmpty
                                                  ? Colors.grey[400]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: Color(0xFFF97419),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context, false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'End Time *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        endTimeController.text.isEmpty
                                            ? 'Select time'
                                            : endTimeController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              endTimeController.text.isEmpty
                                                  ? Colors.grey[400]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: Color(0xFFF97419),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_validateFields()) return;
                    if (!_formKey.currentState!.validate()) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    // Validate time range
                    if (startTimeController.text.isNotEmpty &&
                        endTimeController.text.isNotEmpty) {
                      final startTime = startTimeController.text;
                      final endTime = endTimeController.text;
                      if (startTime.compareTo(endTime) >= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('End time must be after start time'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }

                    final itineraryData = {
                      'itineraryName': itineraryNameController.text,
                      'activities': activitiesController.text,
                      'location': locationController.text,
                      'startTime': startTimeController.text,
                      'endTime': endTimeController.text,
                      'travelPlanId': widget.travelPlanId,
                      'userId': user.uid,
                    };

                    if (widget.existingItinerary != null &&
                        widget.existingItinerary!['id'] != null) {
                      await FirebaseFirestore.instance
                          .collection('itineraries')
                          .doc(widget.existingItinerary!['id'])
                          .update(itineraryData);
                      itineraryData['id'] = widget.existingItinerary!['id']!;
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
                    widget.existingItinerary == null
                        ? 'Save Itinerary'
                        : 'Update Itinerary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF97419),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
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
