import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('appusers')
              .doc(user.uid)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['firstName'];
          lastName = data['lastName'];
          email = data['email'];
          username = data['username'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: Column(
        children: [
          // Header - no rounded corners, blue goes to the very top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            color: const Color(0xFFD6DEFD),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3A5BCE),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "PROFILE",
                        style: TextStyle(
                          color: Color(0xFF3A5BCE),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // No underline
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Centered name and username
                  Text(
                    "${firstName ?? ''} ${lastName ?? ''}",
                    style: const TextStyle(
                      color: Color(0xFF6C7CD1),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    username != null && username!.isNotEmpty
                        ? "@$username"
                        : "@username",
                    style: const TextStyle(
                      color: Color(0xFF6C7CD1),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // User info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "First Name: ${firstName ?? ''}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Last Name: ${lastName ?? ''}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Email: ${email ?? ''}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Interests, Travel Styles, Friends List
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _profileButton("Interests"),
                          const SizedBox(height: 16),
                          _profileButton("Travel Styles"),
                          const SizedBox(height: 16),
                          _profileButton("Friends List"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _profileButton(String label) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFD6DEFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6C7CD1),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
