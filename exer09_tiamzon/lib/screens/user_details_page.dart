import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  final User? user;
  const UserDetailsPage({super.key, required this.user});

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  String? firstName;
  String? lastName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      // Fetch user details from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection("userexpense")
              .doc(widget.user!.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User details not found in Firestore.")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                margin: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "First Name:",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          firstName ?? "N/A",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Last Name:",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          lastName ?? "N/A",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("Email:", style: TextStyle(fontSize: 20)),
                        Text(
                          widget.user!.email!,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
