import 'package:flutter/material.dart';
import 'package:lakbay/screens/similar_people/similar_page.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../home-page/home_page.dart';
import '../travel-page/travel_form.dart';
import 'dart:convert';
import '../../components/bottomnav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  File? _profileImage;
  bool? _makePublic;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserDetails().then((_) {
      setState(() {
        isLoading = false;
        _makePublic = authProvider.userDetails?['public'] ?? false;
      });
    });
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final result = await authProvider.updateProfilePicture(base64Image);

        if (result == null) {
          setState(() {
            _profileImage = file;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile picture: $result')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    final details = authProvider.userDetails;

    // Get base64 image from user details
    final profileImageBase64 =
        details != null ? details['profileImageBase64'] as String? : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null || details == null
              ? const Center(child: Text("No user data available."))
              : Stack(
                children: [
                  // Orange header with logo and back button
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(color: Color(0xFFF97419)),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              Image.asset('assets/logo.png', height: 150),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main content
                  Column(
                    children: [
                      const SizedBox(height: 160),
                      // Fixed top section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile picture (left)
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child:
                                          _profileImage != null
                                              ? Image.file(
                                                _profileImage!,
                                                fit: BoxFit.cover,
                                              )
                                              : profileImageBase64 != null
                                              ? Image.memory(
                                                base64Decode(
                                                  profileImageBase64,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : const DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                // Camera/pencil logic
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                      onPressed: () async {
                                        final source =
                                            await showModalBottomSheet<
                                              ImageSource
                                            >(
                                              context: context,
                                              builder:
                                                  (context) => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.photo_library,
                                                        ),
                                                        title: const Text(
                                                          'Choose from Gallery',
                                                        ),
                                                        onTap:
                                                            () => Navigator.pop(
                                                              context,
                                                              ImageSource
                                                                  .gallery,
                                                            ),
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.camera_alt,
                                                        ),
                                                        title: const Text(
                                                          'Take a Photo',
                                                        ),
                                                        onTap:
                                                            () => Navigator.pop(
                                                              context,
                                                              ImageSource
                                                                  .camera,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                        if (source != null) {
                                          await _handleImageSelection(source);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            const Spacer(),
                            // Edit Profile button (right)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const EditProfilePage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Name, username, email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${details['firstName']} ${details['lastName']}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${details['userName']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Make Profile Public Section
                            Row(
                              children: [
                                Text(
                                  'Make Profile Public',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Switch(
                                  value: _makePublic ?? false,
                                  onChanged: (value) async {
                                    setState(() {
                                      _makePublic = value;
                                    });
                                    final authProvider =
                                        Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await authProvider.updateUserDetails({
                                      'public': value,
                                    });
                                    await authProvider.fetchUserDetails();
                                  },
                                  activeColor: Color(0xFFF97419),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${details['friendsCount'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  ' Friends',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${details['travelPlansCount'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  ' Travel Plans',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Scrollable section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                // Contact Information Container
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Contact Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            details['email'] ??
                                                'No email added',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            details['phoneNumber'] ??
                                                'Add phone number',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Interests
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Interests',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      (details['interests'] as List<dynamic>?)
                                                  ?.isNotEmpty ==
                                              true
                                          ? Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children:
                                                (details['interests']
                                                        as List<dynamic>)
                                                    .map<Widget>((interest) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFF97419,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          interest,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      );
                                                    })
                                                    .toList(),
                                          )
                                          : const Text(
                                            'No interests added yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Travel Styles
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Travel Styles',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      (details['styles'] as List<dynamic>?)
                                                  ?.isNotEmpty ==
                                              true
                                          ? Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children:
                                                (details['styles'] as List<dynamic>).map<
                                                  Widget
                                                >((style) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      style,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          )
                                          : const Text(
                                            'No travel styles added yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}
