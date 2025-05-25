import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/auth_provider.dart';
import 'starting_page.dart';
import 'package:lakbay/screens/itineraries-page/itineraries.dart';
import 'shared_plans_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // control the state of the screen since there are two tabs in the home page
  int _selectedTab = 0;

  void _showShareDialog(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => SharePlanDialog(planId: planId),
    );
  }

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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AuthProvider>().signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => StartingPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFF86400)),
            onPressed: () {
              if (user == null) return;
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Notifications'),
                    content: SizedBox(
                      width: 300,
                      height: 200,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('appusers')
                                .doc(user.uid)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final pending =
                              (data?['pendingRequests'] ?? []) as List;
                          final friends = (data?['friends'] ?? []) as List;
                          if (pending.isEmpty) {
                            return const Center(child: Text('All caught up!'));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: pending.length,
                            itemBuilder: (context, index) {
                              final requesterEmail = pending[index];
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Accept',
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      onPressed: () async {
                                        final userDoc = FirebaseFirestore
                                            .instance
                                            .collection('appusers')
                                            .doc(user.uid);
                                        final requesterQuery =
                                            await FirebaseFirestore.instance
                                                .collection('appusers')
                                                .where(
                                                  'email',
                                                  isEqualTo: requesterEmail,
                                                )
                                                .limit(1)
                                                .get();
                                        if (requesterQuery.docs.isNotEmpty) {
                                          final requesterDoc =
                                              requesterQuery
                                                  .docs
                                                  .first
                                                  .reference;
                                          final requesterData =
                                              requesterQuery.docs.first.data();
                                          final requesterFriends =
                                              List<String>.from(
                                                requesterData['friends'] ?? [],
                                              );

                                          // Remove from pending, add to friends (current user)
                                          final newPending = List<String>.from(
                                            pending,
                                          )..remove(requesterEmail);
                                          final newFriends = List<String>.from(
                                            friends,
                                          );
                                          if (!newFriends.contains(
                                            requesterEmail,
                                          ))
                                            newFriends.add(requesterEmail);

                                          await userDoc.update({
                                            'pendingRequests': newPending,
                                            'friends': newFriends,
                                          });

                                          // Add current user to requester's friends
                                          if (user.email != null &&
                                              !requesterFriends.contains(
                                                user.email,
                                              )) {
                                            requesterFriends.add(user.email!);
                                          }
                                          await requesterDoc.update({
                                            'friends': requesterFriends,
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Decline',
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      onPressed: () async {
                                        final userDoc = FirebaseFirestore
                                            .instance
                                            .collection('appusers')
                                            .doc(user.uid);
                                        final newPending = List<String>.from(
                                          pending,
                                        )..remove(requesterEmail);
                                        await userDoc.update({
                                          'pendingRequests': newPending,
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                title: StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collection('appusers')
                                          .where(
                                            'email',
                                            isEqualTo: requesterEmail,
                                          )
                                          .limit(1)
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Text(
                                        'Someone sent you a friend request',
                                      );
                                    }
                                    final requesterData =
                                        snapshot.data!.docs.first.data()
                                            as Map<String, dynamic>;
                                    final requesterUsername =
                                        requesterData['userName'] ??
                                        requesterEmail;
                                    return Text(
                                      '$requesterUsername sent you a friend request',
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
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
                      _selectedTab == 0
                          ? Consumer<PlanProvider>(
                            builder: (context, planProvider, _) {
                              final plansStream = planProvider.plans;
                              if (plansStream == null) {
                                return Text(
                                  'No travel plans yet.',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 18,
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
                                    return CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFF86400),
                                      ),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Text(
                                      'No results found.',
                                      style: TextStyle(
                                        color: Color(0xFF757575),
                                        fontSize: 18,
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
                                      return Dismissible(
                                        key: Key(planId),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          color: Colors.red,
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          // Optionally, show a confirmation dialog
                                          return await showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text('Delete Plan'),
                                                  content: Text(
                                                    'Are you sure you want to delete this travel plan?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                        onDismissed: (direction) async {
                                          await FirebaseFirestore.instance
                                              .collection('travelplans')
                                              .doc(planId)
                                              .delete();

                                          // Delete all itineraries with this travel plan id
                                          final itineraries =
                                              await FirebaseFirestore.instance
                                                  .collection('itineraries')
                                                  .where(
                                                    'travelPlanId',
                                                    isEqualTo: planId,
                                                  )
                                                  .get();

                                          for (var doc in itineraries.docs) {
                                            await doc.reference.delete();
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Travel plan deleted',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ),
                                          child: SizedBox(
                                            height: 140,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 120,
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
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                  height: 1.0,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.share,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            tooltip:
                                                                'Share Plan',
                                                            onPressed:
                                                                () =>
                                                                    _showShareDialog(
                                                                      context,
                                                                      planId,
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                      Transform.translate(
                                                        offset: const Offset(
                                                          0,
                                                          0,
                                                        ),
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
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                  height: 1.0,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                (() {
                                                                  final dateValue =
                                                                      plan['departureDate'];
                                                                  if (dateValue ==
                                                                      null)
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
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .grey[700],
                                                                  height: 1.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                          : const SharedPlans(),
                ),
              ),

              // Bottom Navigation Bar
            ],
          ),
        ),
      ),
    );
  }
}
