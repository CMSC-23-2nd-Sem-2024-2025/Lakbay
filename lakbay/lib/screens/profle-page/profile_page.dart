import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lakbay/screens/home-page/starting_page.dart';

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
    if (authProvider.userDetails == null) {
      isLoading = true;
      authProvider.fetchUserDetails().then((_) {
        setState(() {
          isLoading = false;
          _makePublic = authProvider.userDetails?['public'] ?? false;
        });
      });
    } else {
      isLoading = false;
      _makePublic = authProvider.userDetails?['public'] ?? false;
    }
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
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97419)),
                ),
              )
              : user == null || details == null
              ? const Center(child: Text("No user data available."))
              : Stack(
                children: [
                  // Logout button at top left
                  Positioned(
                    top: 40,
                    left: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const StartingPage()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFFF86400),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  // Edit button at top right, aligned with profile picture
                  Positioned(
                    top: 40,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      // Profile picture, name, email (centered)
                      Center(
                        child: Column(
                          children: [
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
                                      width: 120,
                                      height: 120,
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
                                        Icons.camera_alt_rounded,
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
                            const SizedBox(height: 12),
                            Text(
                              '${details['firstName']} ${details['lastName']}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${details['userName'] ?? 'No username'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Four cards for Friends, Travel Plans, Interests, and Travel Styles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Friends Card
                                StreamBuilder<DocumentSnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('appusers')
                                          .doc(user.uid)
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    final friends =
                                        (snapshot.hasData &&
                                                snapshot.data!.exists)
                                            ? (snapshot.data!.data()
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >)['friends']
                                                    as List<dynamic>? ??
                                                []
                                            : [];
                                    return _ProfileStatCard(
                                      count: friends.length,
                                      label: 'Friends',
                                      color: Colors.black,
                                      width: 70,
                                      height: 60,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Travel Plans Card
                                StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('travelplans')
                                          .where('userId', isEqualTo: user.uid)
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    final count =
                                        snapshot.hasData
                                            ? snapshot.data!.docs.length
                                            : 0;
                                    return _ProfileStatCard(
                                      count: count,
                                      label: 'Plans',
                                      color: Colors.black,
                                      width: 70,
                                      height: 60,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Interests Card
                                _ProfileStatCard(
                                  count:
                                      (details['interests'] as List<dynamic>?)
                                          ?.length ??
                                      0,
                                  label: 'Interests',
                                  color: Colors.black,
                                  width: 70,
                                  height: 60,
                                ),
                                const SizedBox(width: 8),
                                // Travel Styles Card
                                _ProfileStatCard(
                                  count:
                                      (details['styles'] as List<dynamic>?)
                                          ?.length ??
                                      0,
                                  label: 'Styles',
                                  color: Colors.black,
                                  width: 70,
                                  height: 60,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Make Profile Public Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF97419,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.contact_mail,
                                              color: Color(0xFFF97419),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Contact Information',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.email,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
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
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.phone,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
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
                                const SizedBox(height: 20),
                                // Interests
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF97419,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.interests,
                                              color: Color(0xFFF97419),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Interests',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      (details['interests'] as List<dynamic>?)
                                                  ?.isNotEmpty ==
                                              true
                                          ? Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children:
                                                (details['interests'] as List<dynamic>).map<
                                                  Widget
                                                >((interest) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFFF97419),
                                                              Color(0xFFFF8F3F),
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFFF97419,
                                                          ).withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      interest,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
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
                                const SizedBox(height: 20),
                                // Travel Styles
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFF97419,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.directions_walk,
                                              color: Color(0xFFF97419),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Travel Styles',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
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
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      style,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
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

class _ProfileStatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final double width;
  final double height;
  const _ProfileStatCard({
    required this.count,
    required this.label,
    required this.color,
    this.width = 100,
    this.height = 80,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
