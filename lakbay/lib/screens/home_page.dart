import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'starting_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    final userDetails = authProvider.userDetails;

    String username =
        userDetails?['userName'] ?? user?.email?.split('@')[0] ?? "User";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => StartingPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: DrawerWidget(user: user),
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: "Hi, $username!\n"),
                          const TextSpan(
                            text: "LAKBAY",
                            style: TextStyle(
                              color: Color(0xFFF86400),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: "IN NATIN!",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "Travel Plan",
                                style: TextStyle(
                                  color:
                                      _selectedTab == 0
                                          ? Color(0xFFF86400)
                                          : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 2,
                                width: 70,
                                color:
                                    _selectedTab == 0
                                        ? Color(0xFFF86400)
                                        : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "Shared Plans",
                                style: TextStyle(
                                  color:
                                      _selectedTab == 1
                                          ? Color(0xFFF86400)
                                          : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 2,
                                width: 90,
                                color:
                                    _selectedTab == 1
                                        ? Color(0xFFF86400)
                                        : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Content
              Expanded(
                child: Center(
                  child:
                      _selectedTab == 0
                          ? Text(
                            "No travel plans yet.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          )
                          : GestureDetector(
                            child: Text(
                              "No shared plans yet.",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                ),
              ),
              // Bottom Navigation Bar
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.people_alt_rounded, // 2-person icon
                          color: Color(0xFFF86400),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedTab = 1;
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF86400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            // Add new plan action
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.person, color: Color(0xFFF86400)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
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
