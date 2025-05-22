import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakbay/screens/itineraries-page/itineraries.dart';
import 'package:lakbay/providers/shared_plans_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/models/shared_plans_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lakbay/screens/home-page/qr_scanner_page.dart';

class SharedPlans extends StatelessWidget {
  const SharedPlans({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _fetchPlanDetails(String planId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('travelplans')
            .doc(planId)
            .get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> _fetchRecipientDetails(String userId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('appusers')
            .doc(userId)
            .get();
    return doc.data();
  }

  Future<void> _handleScanResult(BuildContext context, String? result) async {
    if (result == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to scan QR codes.'),
        ),
      );
      return;
    }

    // Fetch the plan to get the ownerId
    final planDoc =
        await FirebaseFirestore.instance
            .collection('travelplans')
            .doc(result)
            .get();
    final planData = planDoc.data();
    if (planData == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Travel plan not found.')));
      }
      return;
    }
    final ownerId = planData['userId'];
    if (ownerId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner not found for this plan.')),
        );
      }
      return;
    }

    try {
      final sharedPlansProvider = Provider.of<SharedPlansProvider>(
        context,
        listen: false,
      );
      await sharedPlansProvider.sharePlanWithUserId(
        planId: result,
        ownerId: ownerId,
        sharedWithUserId: user.uid,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view shared plans'));
    }
    final sharedPlansProvider = Provider.of<SharedPlansProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFFF86400),
            unselectedLabelColor: Colors.black,
            tabs: [Tab(text: 'Shared with Me'), Tab(text: 'Shared by Me')],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerPage(),
                  ),
                );
                if (context.mounted) {
                  await _handleScanResult(context, result);
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF86400),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Plans shared with me
                StreamBuilder<List<SharedPlan>>(
                  stream: sharedPlansProvider.plansSharedWithMe,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sharedPlans = snapshot.data ?? [];
                    if (sharedPlans.isEmpty) {
                      return const Center(
                        child: Text('No plans shared with you yet'),
                      );
                    }
                    return ListView.builder(
                      itemCount: sharedPlans.length,
                      itemBuilder: (context, index) {
                        final sharedPlan = sharedPlans[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _fetchPlanDetails(sharedPlan.planId),
                          builder: (context, planSnapshot) {
                            if (!planSnapshot.hasData ||
                                planSnapshot.data == null) {
                              return const SizedBox.shrink();
                            }
                            final plan = planSnapshot.data!;
                            return _buildPlanCard(
                              context,
                              plan,
                              sharedPlan.id ?? '',
                              isOwner: false,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                // Plans shared by me
                StreamBuilder<List<SharedPlan>>(
                  stream: sharedPlansProvider.plansSharedByMe,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sharedPlans = snapshot.data ?? [];
                    if (sharedPlans.isEmpty) {
                      return const Center(
                        child: Text("You haven't shared any plans yet"),
                      );
                    }
                    return ListView.builder(
                      itemCount: sharedPlans.length,
                      itemBuilder: (context, index) {
                        final sharedPlan = sharedPlans[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _fetchPlanDetails(sharedPlan.planId),
                          builder: (context, planSnapshot) {
                            if (!planSnapshot.hasData ||
                                planSnapshot.data == null) {
                              return const SizedBox.shrink();
                            }
                            final plan = planSnapshot.data!;
                            return FutureBuilder<Map<String, dynamic>?>(
                              future: _fetchRecipientDetails(
                                sharedPlan.sharedWith,
                              ),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData ||
                                    userSnapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                final recipient = userSnapshot.data!;
                                return _buildPlanCard(
                                  context,
                                  plan,
                                  sharedPlan.id ?? '',
                                  isOwner: true,
                                  recipientName: recipient['userName'],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    Map<String, dynamic> plan,
    String sharedPlanId, {
    required bool isOwner,
    String? recipientName,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, color: Colors.orange, size: 32),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ItinerariesPage(plan: plan),
                              ),
                            );
                          },
                          child: Text(
                            plan['travelName'] ?? 'No Name',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Shared with: $recipientName',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItinerariesPage(plan: plan),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['location'] ?? 'No Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (() {
                            final dateValue = plan['departureDate'];
                            if (dateValue == null) return 'No Date';
                            if (dateValue is Timestamp) {
                              final date = dateValue.toDate();
                              return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            }
                            try {
                              final date = DateTime.parse(dateValue.toString());
                              return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            } catch (_) {
                              return dateValue.toString();
                            }
                          })(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
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
  }
}

class SharePlanDialog extends StatefulWidget {
  final String planId;
  const SharePlanDialog({Key? key, required this.planId}) : super(key: key);

  @override
  State<SharePlanDialog> createState() => _SharePlanDialogState();
}

class _SharePlanDialogState extends State<SharePlanDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;

  Future<void> _handleShare() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _error = 'Please enter a username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sharedPlansProvider = Provider.of<SharedPlansProvider>(
        context,
        listen: false,
      );
      await sharedPlansProvider.sharePlanWithUsername(
        planId: widget.planId,
        username: username,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Plan'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [Tab(text: 'By Username'), Tab(text: 'By QR Code')],
            ),
            SizedBox(
              height: 180,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // By Username
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Recipient Username',
                          errorText: _error,
                          enabled: !_isLoading,
                        ),
                        onSubmitted: (_) => _handleShare(),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                  // By QR Code
                  Center(child: QrImageView(data: widget.planId, size: 140.0)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_tabController.index == 0)
          ElevatedButton(
            onPressed: _isLoading ? null : _handleShare,
            child: const Text('Share'),
          ),
      ],
    );
  }
}
