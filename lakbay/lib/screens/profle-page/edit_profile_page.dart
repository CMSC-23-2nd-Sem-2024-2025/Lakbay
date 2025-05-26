import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart'; // Add this import for TextInputFormatter

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _interestsController;
  late TextEditingController _stylesController;
  late TextEditingController _phoneNumberController;
  bool _isLoading = false;
  final List<String> _interestOptions = [
    'Hiking & Trekking',
    'Photography',
    'Art & Museums',
    'Cultures & Religions',
    'Nature & Wildlife',
    'Shopping',
    'Food & Local Cuisine',
    'Nightlife',
    'Festivals',
    'Fitness & Wellness',
  ];
  List<String> _selectedInterests = [];
  final List<String> _styleOptions = [
    'Solo Travel',
    'Group Travel',
    'Luxury',
    'Study Tours',
    'Backpacking',
    'Road Trip',
    'Romantic Getaway',
    'Budget Friendly',
    'Pet-friendly',
    'Extreme Travel',
  ];
  List<String> _selectedStyles = [];

  @override
  void initState() {
    super.initState();
    final details =
        Provider.of<AuthProvider>(context, listen: false).userDetails;
    _fullNameController = TextEditingController(
      text:
          details != null
              ? "${details['firstName']} ${details['lastName']}"
              : '',
    );
    _selectedInterests =
        (details?['interests'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    _interestsController = TextEditingController(
      text: _selectedInterests.isEmpty ? '' : _selectedInterests.join(', '),
    );
    _selectedStyles =
        (details?['styles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    _stylesController = TextEditingController(
      text: _selectedStyles.isEmpty ? '' : _selectedStyles.join(', '),
    );
    _phoneNumberController = TextEditingController(
      text: details?['phoneNumber'] ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _interestsController.dispose();
    _stylesController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    final fullName = _fullNameController.text.trim();
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final updatedData = {
      'firstName': firstName,
      'lastName': lastName,
      'interests': _selectedInterests,
      'styles': _selectedStyles,
      'phoneNumber': _phoneNumberController.text.trim(),
    };
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.updateUserDetails(updatedData);
    setState(() {
      _isLoading = false;
    });
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^\d{11}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number is invalid';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97419)),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Color(0xFFF97419),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF97419),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter your full name'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Color(0xFFF97419),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF97419),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: _phoneValidator,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _interestsController,
                              readOnly: true,
                              onTap: () async {
                                final result = await showModalBottomSheet<
                                  List<String>
                                >(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    List<String> tempSelected = List.from(
                                      _selectedInterests,
                                    );
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 32,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 4,
                                                margin: const EdgeInsets.only(
                                                  bottom: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              const Text(
                                                'Select Interests',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Flexible(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _interestOptions.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final option =
                                                        _interestOptions[index];
                                                    return CheckboxListTile(
                                                      title: Text(
                                                        option,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: tempSelected
                                                          .contains(option),
                                                      checkColor: Colors.white,
                                                      activeColor: const Color(
                                                        0xFFF97419,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      onChanged: (checked) {
                                                        setModalState(() {
                                                          if (checked == true) {
                                                            tempSelected.add(
                                                              option,
                                                            );
                                                          } else {
                                                            tempSelected.remove(
                                                              option,
                                                            );
                                                          }
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      tempSelected,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFF97419),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Done',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                if (result != null) {
                                  setState(() {
                                    _selectedInterests = result;
                                    _interestsController
                                        .text = _selectedInterests.join(', ');
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Interests',
                                labelStyle: const TextStyle(color: Colors.grey),
                                hintText: 'Select your interests',
                                prefixIcon: const Icon(
                                  Icons.interests,
                                  color: Color(0xFFF97419),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF97419),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _stylesController,
                              readOnly: true,
                              onTap: () async {
                                final result = await showModalBottomSheet<
                                  List<String>
                                >(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    List<String> tempSelected = List.from(
                                      _selectedStyles,
                                    );
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 32,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 4,
                                                margin: const EdgeInsets.only(
                                                  bottom: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              const Text(
                                                'Select Travel Styles',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Flexible(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _styleOptions.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final option =
                                                        _styleOptions[index];
                                                    return CheckboxListTile(
                                                      title: Text(
                                                        option,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      value: tempSelected
                                                          .contains(option),
                                                      checkColor: Colors.white,
                                                      activeColor: const Color(
                                                        0xFFF97419,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      onChanged: (checked) {
                                                        setModalState(() {
                                                          if (checked == true) {
                                                            tempSelected.add(
                                                              option,
                                                            );
                                                          } else {
                                                            tempSelected.remove(
                                                              option,
                                                            );
                                                          }
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      tempSelected,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFF97419),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Done',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                if (result != null) {
                                  setState(() {
                                    _selectedStyles = result;
                                    _stylesController.text = _selectedStyles
                                        .join(', ');
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Travel Styles',
                                labelStyle: const TextStyle(color: Colors.grey),
                                hintText: 'Select your travel styles',
                                prefixIcon: const Icon(
                                  Icons.directions_walk,
                                  color: Color(0xFFF97419),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF97419),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97419),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }
}
