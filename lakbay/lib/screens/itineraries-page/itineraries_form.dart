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
  late TextEditingController dateController;
  LatLong? selectedLocation;
  DateTime? selectedDate;
  DateTime? travelPlanStartDate;
  DateTime? travelPlanEndDate;

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
    dateController = TextEditingController(
      text: widget.existingItinerary?['date'] ?? '',
    );

    // Initialize selectedDate from existing itinerary
    final existingDate = widget.existingItinerary?['date'];
    if (existingDate != null && existingDate.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(existingDate);
        dateController.text =
            "${_getMonthName(selectedDate!.month)} ${selectedDate!.day}, ${selectedDate!.year}";
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    locationController.addListener(() {
      setState(() {});
    });

    // Fetch travel plan dates
    _fetchTravelPlanDates();
  }

  Future<void> _fetchTravelPlanDates() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('travelplans')
            .doc(widget.travelPlanId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        travelPlanStartDate = DateTime.parse(data['departureDate']);
        travelPlanEndDate = DateTime.parse(data['returnDate']);
      });
    }
  }

  @override
  void dispose() {
    itineraryNameController.dispose();
    activitiesController.dispose();
    locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (travelPlanStartDate == null || travelPlanEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load travel plan dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? travelPlanStartDate!,
      firstDate: travelPlanStartDate!,
      lastDate: travelPlanEndDate!,
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
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
        dateController.text =
            "${_getMonthName(picked.month)} ${picked.day}, ${picked.year}";
      });
    }
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

  Future<bool> _checkOverlappingItineraries() async {
    if (selectedDate == null ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty) {
      return false;
    }

    // Get all itineraries for the selected date
    final itineraries =
        await FirebaseFirestore.instance
            .collection('itineraries')
            .where('travelPlanId', isEqualTo: widget.travelPlanId)
            .where(
              'date',
              isEqualTo: selectedDate!.toIso8601String().split('T')[0],
            )
            .get();

    final newStartTime = startTimeController.text;
    final newEndTime = endTimeController.text;

    for (var doc in itineraries.docs) {
      final data = doc.data();
      // Skip current itinerary when editing
      if (widget.existingItinerary != null &&
          widget.existingItinerary!['id'] == doc.id) {
        continue;
      }

      final existingStartTime = data['startTime'] as String;
      final existingEndTime = data['endTime'] as String;

      // Check for overlap
      if ((newStartTime.compareTo(existingStartTime) >= 0 &&
              newStartTime.compareTo(existingEndTime) < 0) ||
          (newEndTime.compareTo(existingStartTime) > 0 &&
              newEndTime.compareTo(existingEndTime) <= 0) ||
          (newStartTime.compareTo(existingStartTime) <= 0 &&
              newEndTime.compareTo(existingEndTime) >= 0)) {
        return true;
      }
    }
    return false;
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
              SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () => _selectDate(context),
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

                    // Check for overlapping itineraries
                    if (await _checkOverlappingItineraries()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'This time slot overlaps with an existing itinerary',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final itineraryData = {
                      'itineraryName': itineraryNameController.text,
                      'activities': activitiesController.text,
                      'location': locationController.text,
                      'date': selectedDate?.toIso8601String().split('T')[0],
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
}
