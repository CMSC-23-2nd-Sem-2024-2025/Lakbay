import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:lakbay/screens/travel-page/travel_form.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import 'starting_page.dart';
import '../profle-page/profile_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries.dart';

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
      body: SizedBox(
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
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(
                            text: "IN NATIN!",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
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
                          // through this provider, this enables the stream to fetch the data from the firestore
                          // the data is being fetched in travelplans collection
                          ? Consumer<PlanProvider>(
                            builder: (context, planProvider, _) {
                              final plansStream = planProvider.plans;
                              if (plansStream == null) {
                                return Text(
                                  "No travel plans yet.",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                );
                              }

                              // through streambuilder, data from the plans stream is fetched
                              // the data is then displayed in a list view
                              return StreamBuilder(
                                stream: plansStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Text(
                                      "No travel plans yet.",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    );
                                  }
                                  final plans = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: plans.length,
                                    itemBuilder: (context, index) {
                                      final plan =
                                          plans[index].data()
                                              as Map<String, dynamic>;

                                      // ths makes the added travel plans to be clickable
                                      // clicking the travel plan will directs the itineraries page
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ItinerariesPage(plan: plan),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ),
                                          child: SizedBox(
                                            height: 150,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 140,
                                                  height: 110,
                                                  margin: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.orange,
                                                    size: 32,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        plan['travelName'] ??
                                                            'No Name',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 24,
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        plan['location'] ??
                                                            'No Location',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        (() {
                                                          final dateValue =
                                                              plan['departureDate'];
                                                          if (dateValue == null)
                                                            return 'No Date';
                                                          if (dateValue
                                                              is Timestamp) {
                                                            final date =
                                                                dateValue
                                                                    .toDate();
                                                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                                          }
                                                          try {
                                                            final date =
                                                                DateTime.parse(
                                                                  dateValue
                                                                      .toString(),
                                                                );
                                                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                                          } catch (_) {
                                                            return dateValue
                                                                .toString();
                                                          }
                                                        })(),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TravelFormPage(),
                              ),
                            );
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
