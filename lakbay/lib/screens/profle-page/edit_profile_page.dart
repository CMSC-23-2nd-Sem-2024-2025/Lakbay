import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'profile_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _interestsController;
  late TextEditingController _stylesController;
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
    _usernameController = TextEditingController(
      text: details?['userName'] ?? '',
    );
    _emailController = TextEditingController(text: details?['email'] ?? '');
    _selectedInterests =
        (details?['interests'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    _interestsController = TextEditingController(
      text: _selectedInterests.join(', '),
    );
    _selectedStyles =
        (details?['styles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    _stylesController = TextEditingController(text: _selectedStyles.join(', '));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _interestsController.dispose();
    _stylesController.dispose();
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
      'userName': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'interests': _selectedInterests,
      'styles': _selectedStyles,
    };
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.updateUserDetails(updatedData);
    setState(() {
      _isLoading = false;
    });
    if (result == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter your full name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter your username'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter your email'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _interestsController,
                        readOnly: true,
                        onTap: () async {
                          final result =
                              await showModalBottomSheet<List<String>>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  List<String> tempSelected = List.from(
                                    _selectedInterests,
                                  );
                                  return StatefulBuilder(
                                    builder: (context, setModalState) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 32,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Select Interests',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ..._interestOptions.map(
                                              (option) => CheckboxListTile(
                                                title: Text(option),
                                                value: tempSelected.contains(
                                                  option,
                                                ),
                                                onChanged: (checked) {
                                                  setModalState(() {
                                                    if (checked == true) {
                                                      tempSelected.add(option);
                                                    } else {
                                                      tempSelected.remove(
                                                        option,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                  tempSelected,
                                                );
                                              },
                                              child: const Text('Done'),
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
                              _interestsController.text = _selectedInterests
                                  .join(', ');
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Interests',
                          hintText: 'Select your interests',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stylesController,
                        readOnly: true,
                        onTap: () async {
                          final result =
                              await showModalBottomSheet<List<String>>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  List<String> tempSelected = List.from(
                                    _selectedStyles,
                                  );
                                  return StatefulBuilder(
                                    builder: (context, setModalState) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 32,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Select Travel Styles',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ..._styleOptions.map(
                                              (option) => CheckboxListTile(
                                                title: Text(option),
                                                value: tempSelected.contains(
                                                  option,
                                                ),
                                                onChanged: (checked) {
                                                  setModalState(() {
                                                    if (checked == true) {
                                                      tempSelected.add(option);
                                                    } else {
                                                      tempSelected.remove(
                                                        option,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                  tempSelected,
                                                );
                                              },
                                              child: const Text('Done'),
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
                              _stylesController.text = _selectedStyles.join(
                                ', ',
                              );
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Travel Styles',
                          hintText: 'Select your travel styles',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97419),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
