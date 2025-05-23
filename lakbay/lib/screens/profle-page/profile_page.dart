import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../home-page/home_page.dart';
import '../travel-page/travel_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserDetails().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // make an instance of the auth provider to get user data
    final authProvider = Provider.of<AuthProvider>(context);

    // make the user object to and details
    final user = authProvider.userObj;
    final details = authProvider.userDetails;
    bool makePublic = details?['public'] ?? false;

    // image for storing to firebase
    final profileImageUrl =
        details != null ? details['profileImageUrl'] as String? : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body:
          isLoading
              // apply a loading widget if data is still being fetched
              ? const Center(child: CircularProgressIndicator())
              : user == null || details == null
              ? const Center(child: Text("No user data available."))
              : Stack(
                children: [
                  // Orange header with logo and back button
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(color: Color(0xFFF97419)),

                    // add the logo
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 160),
                        // Profile picture and Edit Profile button in a row
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
                                            // get the image
                                            _profileImage != null
                                                ? Image.file(
                                                  _profileImage!,
                                                  fit: BoxFit.cover,
                                                )
                                                : (profileImageUrl != null &&
                                                    profileImageUrl.isNotEmpty)
                                                ? Image.network(
                                                  profileImageUrl,
                                                  fit: BoxFit.cover,
                                                )
                                                : DecoratedBox(
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.grey,
                                                      ),
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  // Camera/pencil logic (unchanged)
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
                                                              () =>
                                                                  Navigator.pop(
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
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    ImageSource
                                                                        .camera,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                          if (source != null) {
                                            final picked = await ImagePicker()
                                                .pickImage(
                                                  source: source,
                                                  imageQuality: 85,
                                                );
                                            if (picked != null) {
                                              setState(() {
                                                _profileImage = File(
                                                  picked.path,
                                                );
                                              });
                                            }
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
                              const SizedBox(height: 4),
                              Text(
                                details['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                details['phoneNumber'] ?? 'Add phone number',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),

                              Row(

                                children: [

                                  Text('Make Profile Public',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  ),

                                  SizedBox(width: 2),

                                  Switch(
                                value: makePublic,
  onChanged: (value) async {
    // Update in Firestore via AuthProvider
    await Provider.of<AuthProvider>(context, listen: false)
        .updateUserDetails({'public': value});
    setState(() {}); // Refresh UI
  },
  activeColor: Color(0xFFF97419),
                              ),
                                ],
                              ),

                              const SizedBox(height: 12),
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
                        const SizedBox(height: 24),
                        // Interests
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Interests',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                        ),
                        const SizedBox(height: 18),
                        // Travel Styles
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Travel Styles',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                (details['styles'] as List<dynamic>?)
                                            ?.isNotEmpty ==
                                        true
                                    ? Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children:
                                          (details['styles'] as List<dynamic>)
                                              .map<Widget>((style) {
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
                                              })
                                              .toList(),
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
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
      // Add bottom navigation bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFFF86400),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
                  );
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF86400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TravelFormPage()),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Color(0xFFF86400)),
                onPressed: () {
                  // Already on profile page, do nothing
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
