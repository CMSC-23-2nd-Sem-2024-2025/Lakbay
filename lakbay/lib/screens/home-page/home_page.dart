import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  // control the state of the screen since there are two tabs in the home page
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // make an instance of the auth provider to get the user object and obtain the details of auth user
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    final userDetails = authProvider.userDetails;

    // make a string username to store it in a text widget later. if the username is null, use email (bakit guys???)
    String username =
        userDetails?['userName'] ?? user?.email?.split('@')[0] ?? "User";

    // this is the main scaffold of the home page. it contains the app bar, body, and bottom navigation bar
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        // add the app drawer
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

                    // this makes the row for the tab selection
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab =
                                  0; //updates the value of the selected (will be used later)
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
                      // since nakabase yung selected tab sa gestuer provider sa taas magagamit sya to make a condition
                      // and use a consumer provider to either fetch the users trravel plan or the shared plan based on the
                      // selected tab
                      _selectedTab ==
                              0 //
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
                                      final planId = plans[index].id;
                                      return Card(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 8,
                                        ),
                                        child: SizedBox(
                                          height: 100,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 100,
                                                margin: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => ItinerariesPage(
                                                                        plan:
                                                                            plan,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              plan['travelName'] ??
                                                                  'No Name',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        SizedBox(
                                                          width: 28,
                                                          height: 28,
                                                          child: IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            icon: Icon(
                                                              Icons.delete,
                                                              size: 20,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () async {
                                                              final confirm = await showDialog<
                                                                bool
                                                              >(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => AlertDialog(
                                                                      title: Text(
                                                                        'Delete Travel Plan',
                                                                      ),
                                                                      content: Text(
                                                                        'Are you sure you want to delete this travel plan?',
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () => Navigator.pop(
                                                                                context,
                                                                                false,
                                                                              ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () => Navigator.pop(
                                                                                context,
                                                                                true,
                                                                              ),
                                                                          child: Text(
                                                                            'Delete',
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.red,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                              );
                                                              if (confirm ==
                                                                  true) {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                      'travelplans',
                                                                    )
                                                                    .doc(planId)
                                                                    .delete();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ItinerariesPage(
                                                                      plan:
                                                                          plan,
                                                                    ),
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            plan['location'] ??
                                                                'No Location',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[700],
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            (() {
                                                              final dateValue =
                                                                  plan['departureDate'];
                                                              if (dateValue ==
                                                                  null) {
                                                                return 'No Date';
                                                              }
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
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          )
                          // else, return this text instead
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
