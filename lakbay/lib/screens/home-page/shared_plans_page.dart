import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakbay/screens/itineraries-page/itineraries.dart';
import 'package:lakbay/providers/shared_plans_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/models/shared_plans_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lakbay/screens/home-page/qr_scanner_page.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser;
    final isPlanOwner = currentUser?.uid == plan['userId'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, color: Colors.orange, size: 32),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (() {
                            final dateValue = plan['departureDate'];
                            if (dateValue == null) return 'No Date';
                            if (dateValue is Timestamp) {
                              final date = dateValue.toDate();
                              return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
                            }
                            try {
                              final date = DateTime.parse(dateValue.toString());
                              return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
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
                  const SizedBox(height: 6),
                  Text(
                    plan['location'] ?? 'No Location',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (() {
                      final dateValue = plan['departureDate'];
                      if (dateValue == null) return 'No Date';
                      if (dateValue is Timestamp) {
                        final date = dateValue.toDate();
                        return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
                      }
                      try {
                        final date = DateTime.parse(dateValue.toString());
                        return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
                      } catch (_) {
                        return dateValue.toString();
                      }
                    })(),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (isPlanOwner) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Shared with: $recipientName',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'View all shared users',
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.people_outline,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                onPressed:
                                    () => _showSharedUsersDialog(
                                      context,
                                      plan['id'],
                                    ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveUserDialog(
    BuildContext context,
    String sharedPlanId,
    String recipientName,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove User'),
            content: Text(
              'Are you sure you want to remove $recipientName from this travel plan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final sharedPlansProvider =
                        Provider.of<SharedPlansProvider>(
                          context,
                          listen: false,
                        );
                    await sharedPlansProvider.removeSharedUser(sharedPlanId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User removed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error removing user: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  Future<void> _showSharedUsersDialog(
    BuildContext context,
    String planId,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the plan details to verify ownership
    final planDoc =
        await FirebaseFirestore.instance
            .collection('travelplans')
            .doc(planId)
            .get();

    if (!planDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Travel plan not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final planData = planDoc.data();
    final isOwner = planData?['userId'] == currentUser.uid;

    // Get all shared plans for this travel plan
    final sharedPlans =
        await FirebaseFirestore.instance
            .collection('sharedplans')
            .where('planId', isEqualTo: planId)
            .get();

    if (sharedPlans.docs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No users have access to this plan yet'),
          ),
        );
      }
      return;
    }

    // Get user details for each shared plan
    final userDetails = await Future.wait(
      sharedPlans.docs.map((doc) async {
        final sharedPlan = SharedPlan.fromJson(doc.data(), id: doc.id);
        final userDoc =
            await FirebaseFirestore.instance
                .collection('appusers')
                .doc(sharedPlan.sharedWith)
                .get();
        return {
          'userId': sharedPlan.sharedWith,
          'username': userDoc.data()?['userName'] ?? 'Unknown User',
          'sharedPlanId': doc.id,
        };
      }),
    );

    if (context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                children: [
                  const Icon(Icons.people_outline, color: Color(0xFFF86400)),
                  const SizedBox(width: 8),
                  const Text(
                    'Shared Users',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: userDetails.length,
                  separatorBuilder:
                      (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final user = userDetails[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFFFE3CC),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFFF86400),
                        ),
                      ),
                      title: Text(
                        user['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      trailing:
                          isOwner
                              ? Tooltip(
                                message: 'Remove user',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFE3CC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Color.fromARGB(255, 217, 22, 22),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showRemoveUserDialog(
                                          context,
                                          user['sharedPlanId'],
                                          user['username'],
                                        );
                                      },
                                      splashRadius: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ),
                              )
                              : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
      );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Share Plan',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
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
                            labelStyle: const TextStyle(color: Colors.black),
                            errorText: _error,
                            enabled: !_isLoading,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _handleShare(),
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                    // By QR Code
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            if (Platform.isAndroid) {
                              if (await Permission.photos.request().isGranted) {
                                await _saveAndShareQRCode(context);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Photos permission is required to save QR code',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              await _saveAndShareQRCode(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QrImageView(
                                  data: widget.planId,
                                  size: 130.0,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Long press to save QR code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        if (_tabController.index == 0)
          ElevatedButton(
            onPressed: _isLoading ? null : _handleShare,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Share'),
          ),
      ],
    );
  }

  Future<void> _saveAndShareQRCode(BuildContext context) async {
    try {
      // Request photos permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photos permission is required to save QR code'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Create a painter to draw the QR code with higher error correction
      final qrPainter = QrPainter(
        data: widget.planId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      // Create a picture recorder with a white background
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(300, 300); // Increased size for better scanning

      // Draw white background
      final paint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawRect(Offset.zero & size, paint);

      // Draw the QR code
      qrPainter.paint(canvas, size);
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Save to gallery
      if (Platform.isAndroid) {
        // Get the Downloads directory
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Save the QR code with a timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${downloadsDir.path}/Lakbay_QR_$timestamp.png');
        await file.writeAsBytes(buffer);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code saved to Downloads folder'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
