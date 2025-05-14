import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? firstName;
  String? username;

  // Sample travel data - in a real app, this would come from Firestore
  final List<Map<String, dynamic>> travelPlans = [
    {
      'id': '1',
      'title': 'Travel Name #1',
      'location': 'Location',
      'date': 'Date',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/lakbay-ce0dc.appspot.com/o/chocolate-hills.jpg?alt=media',
    },
    {
      'id': '2',
      'title': 'Travel Name #2',
      'location': 'Location',
      'date': 'Date',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/lakbay-ce0dc.appspot.com/o/chocolate-hills.jpg?alt=media',
    },
    {
      'id': '3',
      'title': 'Travel Name #3',
      'location': 'Location',
      'date': 'Date',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/lakbay-ce0dc.appspot.com/o/chocolate-hills.jpg?alt=media',
    },
    {
      'id': '4',
      'title': 'Travel Name #4',
      'location': 'Location',
      'date': 'Date',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/lakbay-ce0dc.appspot.com/o/chocolate-hills.jpg?alt=media',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('appusers')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['firstName'] ?? '';
          username = user.email?.split('@')[0] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and logo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${username ?? 'User'}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'LAKBAY',
                                  style: TextStyle(
                                    color: Color(0xFFF86400),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'IN NATIN!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logo at top right
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 1.2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _tabController.index = 0;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Travel Plan',
                            style: TextStyle(
                              color:
                                  _tabController.index == 0
                                      ? const Color(0xFFF86400)
                                      : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 60,
                            color:
                                _tabController.index == 0
                                    ? const Color(0xFFF86400)
                                    : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _tabController.index = 1;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Shared Plans',
                            style: TextStyle(
                              color:
                                  _tabController.index == 1
                                      ? const Color(0xFFF86400)
                                      : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 60,
                            color:
                                _tabController.index == 1
                                    ? const Color(0xFFF86400)
                                    : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification &&
                          notification.metrics is PageMetrics) {
                        final page =
                            (notification.metrics as PageMetrics).page
                                ?.round() ??
                            0;
                        if (_tabController.index != page) {
                          setState(() {
                            _tabController.index = page;
                          });
                        }
                      }
                      return false;
                    },
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Travel Plan Tab
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90, top: 0),
                          itemCount: travelPlans.length,
                          itemBuilder: (context, index) {
                            final plan = travelPlans[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: _buildTravelCard(
                                id: plan['id'],
                                title: plan['title'],
                                location: plan['location'],
                                date: plan['date'],
                                imageUrl: plan['image'],
                              ),
                            );
                          },
                        ),
                        // Shared Plans Tab (empty state, but scrollable for future use)
                        ListView(
                          padding: const EdgeInsets.only(bottom: 90, top: 0),
                          children: const [
                            SizedBox(height: 40),
                            Center(child: Text('No shared plans yet')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTravelCard({
    required String id,
    required String title,
    required String location,
    required String date,
    required String imageUrl,
  }) {
    return Material(
      elevation: 1.2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Travel image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Travel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
              // View button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF86400),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // People icon
          IconButton(
            icon: const Icon(
              Icons.people_outline,
              color: Color(0xFFF86400),
              size: 30,
            ),
            onPressed: () {},
          ),
          // Add button
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF86400),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 32),
              onPressed: () {},
            ),
          ),
          // Person icon
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Color(0xFFF86400),
              size: 30,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
