import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;

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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    final details = authProvider.userDetails;

    return Scaffold(
      drawer: DrawerWidget(user: user),
      appBar: AppBar(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null || details == null
              ? const Center(child: Text("No user data available."))
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text("Lakbay", style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 70),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // User Info Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              top: 100,
                              bottom: 24,
                              left: 16,
                              right: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${details['firstName']} ${details['lastName']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "${details['email']}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          // Profile Picture
                          Positioned(
                            top: -60,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: DecoratedBox(
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          print("Edit Profile Picture");
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          enabled: false,
                          initialValue: details['firstName'],
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: details['firstName'],
                            disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFF97419)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          enabled: false,
                          initialValue: details['userName'],
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Username',
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFF97419)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          enabled: false,
                          initialValue: details['email'],
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Email',
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFF97419)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          enabled: false,
                          initialValue: (details['interests'] as List<dynamic>)
                              .join(', '),
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Interests',
                            hintText: 'Interests',
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFF97419)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          enabled: false,
                          initialValue: (details['styles'] as List<dynamic>)
                              .join(', '),
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Travel Styles',
                            hintText: 'Travel Styles',
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFF97419)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 315,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: BorderSide.none,
                            ),
                          ),
                          child: Text(
                            "Edit Your Profile",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF000000),
                            ),
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
