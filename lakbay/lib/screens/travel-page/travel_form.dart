import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/models/travel_plans_model.dart';
import 'package:lakbay/screens/travel-page/travel_add_info.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:lakbay/services/notification_service.dart';

class TravelFormPage extends StatefulWidget {
  const TravelFormPage({super.key});

  @override
  State<TravelFormPage> createState() => _TravelFormPageState();
}

class _TravelFormPageState extends State<TravelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final departureController = TextEditingController();
  final returnController = TextEditingController();
  final notificationDateController = TextEditingController();
  final notificationTimeController = TextEditingController();
  final imageUrlController = TextEditingController();
  LatLong? selectedLocation;
  bool enableNotifications = false;
  DateTime? notificationDate;
  TimeOfDay? notificationTime;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    locationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    departureController.dispose();
    returnController.dispose();
    notificationDateController.dispose();
    notificationTimeController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    print('Validating fields...'); // Debug print
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    print('Form validation passed'); // Debug print
    return true;
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
                    // use the address from the picked data instead of coordinates
                    locationController.text = pickedData.address;
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

  Future<void> _showNotificationDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF97419),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFF97419)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        notificationDate = pickedDate;
        notificationDateController.text =
            pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFF97419),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFF97419)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        notificationTime = pickedTime;
        notificationTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _showImageUrlDialog() async {
    imageUrlController.text = imageUrl ?? '';
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Image URL'),
            content: TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                hintText: 'Enter image URL',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    imageUrl = imageUrlController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFF97419);

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // for back button
                const SizedBox(height: 16),

                // RichText is used to control the design or style of each word
                // TextSpan allows the user to select and modify the text for changing its font color, style, or size
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),

                    // title of the travel form page
                    children: [
                      TextSpan(text: 'MAKE YOUR '),
                      TextSpan(
                        text: 'TRAVEL\nPLAN ',
                        style: TextStyle(color: orange),
                      ),
                      TextSpan(text: 'AHEAD!'),
                    ],
                  ),
                ),

                const SizedBox(height: 42),

                _Label('Travel Name'),
                _ShadowedTextField(
                  controller: nameController,
                  hintText: 'Enter Travel Name',
                  icon: Icons.flight_takeoff,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter travel name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                _Label('Travel Image'),
                GestureDetector(
                  onTap: _showImageUrlDialog,
                  child: Container(
                    width: double.infinity,
                    height: 200,
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
                    child:
                        imageUrl != null && imageUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 8),
                                        Text('Invalid image URL'),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: orange,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Travel Image',
                                    style: TextStyle(
                                      color: orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 40),

                _Label('Location'),
                _ShadowedTextField(
                  controller: locationController,
                  hintText: 'Tap to select location on map',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                  onTap: _showLocationPicker,
                  readOnly: true,
                ),

                const SizedBox(height: 40),

                _Label('Departure Date'),
                _ShadowedTextField(
                  controller: departureController,
                  hintText: 'Select Departure Date',
                  icon: Icons.date_range,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select departure date';
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime firstDate = DateTime(
                      now.year,
                      now.month,
                      now.day,
                    );

                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: DateTime(2100),
                      initialDate: firstDate,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFF97419),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFFF97419),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        departureController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                  readOnly: true,
                ),

                const SizedBox(height: 40),

                _Label('Return Date'),
                _ShadowedTextField(
                  controller: returnController,
                  hintText: 'Select Return Date',
                  icon: Icons.calendar_today_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select return date';
                    }
                    // Validate that return date is after departure date
                    if (departureController.text.isNotEmpty) {
                      final departure = DateTime.parse(
                        departureController.text,
                      );
                      final returnDate = DateTime.parse(value);
                      if (returnDate.isBefore(departure)) {
                        return 'Return date must be after departure date';
                      }
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime firstDate =
                        departureController.text.isNotEmpty
                            ? DateTime.parse(departureController.text)
                            : DateTime(now.year, now.month, now.day);

                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: firstDate,
                      firstDate: firstDate,
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFF97419),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFFF97419),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        returnController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                  readOnly: true,
                ),

                const SizedBox(height: 40),

                // Notification Settings Section
                _Label('Notification Settings'),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: enableNotifications,
                            onChanged: (value) {
                              setState(() {
                                enableNotifications = value;
                                if (!value) {
                                  notificationDate = null;
                                  notificationTime = null;
                                  notificationDateController.clear();
                                  notificationTimeController.clear();
                                }
                              });
                            },
                            activeColor: orange,
                          ),
                        ],
                      ),
                      if (enableNotifications) ...[
                        SizedBox(height: 16),
                        _Label('Notification Date'),
                        _ShadowedTextField(
                          controller: notificationDateController,
                          hintText: 'Select notification date',
                          icon: Icons.calendar_today,
                          onTap: _showNotificationDatePicker,
                          readOnly: true,
                          validator: (value) {
                            if (enableNotifications &&
                                (value == null || value.isEmpty)) {
                              return 'Please select notification date';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('Notification Time'),
                        _ShadowedTextField(
                          controller: notificationTimeController,
                          hintText: 'Select notification time',
                          icon: Icons.access_time,
                          onTap: _showTimePicker,
                          readOnly: true,
                          validator: (value) {
                            if (enableNotifications &&
                                (value == null || value.isEmpty)) {
                              return 'Please select notification time';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final notificationService =
                                    NotificationService();
                                await notificationService
                                    .showTestNotification();
                              },
                              icon: Icon(Icons.notifications_active),
                              label: Text('Test Notification'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Next Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Next button pressed'); // Debug print
                      if (_validateFields()) {
                        print('Creating travel plan...'); // Debug print
                        final travelPlan = _createTravelPlan();
                        print(
                          'Travel plan created, navigating to next page...',
                        ); // Debug print

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TravelAddInfoPage(travelPlan: travelPlan),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TravelPlan _createTravelPlan() {
    // Combine notification date and time if both are set
    DateTime? combinedNotificationTime;
    if (notificationDate != null && notificationTime != null) {
      // Create a DateTime object with the selected date and time
      combinedNotificationTime = DateTime(
        notificationDate!.year,
        notificationDate!.month,
        notificationDate!.day,
        notificationTime!.hour,
        notificationTime!.minute,
      );

      // Verify the time is in the future
      final now = DateTime.now();
      if (combinedNotificationTime.isBefore(now)) {
        // Set to 1 minute in the future for testing
        combinedNotificationTime = now.add(Duration(minutes: 1));
      }
    }

    print('Creating travel plan with image URL: $imageUrl'); // Add debug print
    final plan = TravelPlan(
      userId: FirebaseAuth.instance.currentUser!.uid,
      travelName: nameController.text,
      location: locationController.text,
      departureDate: DateTime.parse(departureController.text),
      returnDate: DateTime.parse(returnController.text),
      enableNotifications: enableNotifications,
      notificationTime: combinedNotificationTime,
      imageUrl: imageUrl,
    );
    print('Created plan with image URL: ${plan.imageUrl}'); // Add debug print
    return plan;
  }
}

// for custom lable widget
// reusable widget
// used for displaying name of the field ("Travel Name", "Location")
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {super.key});

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

// for custom shadowed text field widget
// this gives shadow effect to each text field
class _ShadowedTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool readOnly;
  final TextInputType? keyboardType;

  const _ShadowedTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onTap,
    this.validator,
    this.readOnly = false,
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
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
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
          errorStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
