import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userObj != null && authProvider.userDetails == null) {
      authProvider.fetchUserDetails().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;

    if (isLoading || user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFF86400)),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('appusers')
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFF86400)),
              ),
            ),
          );
        }
        final userDetails = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 35, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Friends',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF97419),
                        ),
                      ),
                      Image.asset('assets/or.png', height: 50),
                    ],
                  ),
                  Text(
                    'Make connections',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final friends = (userDetails['friends'] ?? []) as List;
                        if (friends.isEmpty) {
                          return const Center(
                            child: Text(
                              'No friends yet.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF757575),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('appusers')
                                  .where(
                                    'email',
                                    whereIn:
                                        friends.length > 10
                                            ? friends.sublist(0, 10)
                                            : friends,
                                  )
                                  .snapshots(),
                          builder: (context, friendSnapshot) {
                            if (!friendSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final docs = friendSnapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No results found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.62,
                                  ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final u =
                                    docs[index].data() as Map<String, dynamic>;
                                final friendEmail = u['email'] as String?;
                                return GestureDetector(
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: 'Friend Details',
                                      transitionDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      pageBuilder: (context, anim1, anim2) {
                                        return AlertDialog(
                                          content: SizedBox(
                                            width: 300,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: _buildProfileImage(u),
                                                ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: Text(
                                                    '@${u['userName']}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFFF86400),
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                _buildDetailSection(
                                                  'Name',
                                                  '${u['firstName']} ${u['lastName']}',
                                                ),
                                                const SizedBox(height: 16),
                                                _buildDetailSection(
                                                  'Email',
                                                  u['email'] ?? 'Not available',
                                                ),
                                                const SizedBox(height: 16),
                                                _buildDetailSection(
                                                  'Interests',
                                                  ((u['interests']
                                                                  as List<
                                                                    dynamic
                                                                  >?) ==
                                                              null ||
                                                          (u['interests']
                                                                  as List<
                                                                    dynamic
                                                                  >?)!
                                                              .isEmpty)
                                                      ? 'None'
                                                      : (u['interests']
                                                              as List<dynamic>)
                                                          .join(", "),
                                                ),
                                                const SizedBox(height: 16),
                                                _buildDetailSection(
                                                  'Travel Styles',
                                                  ((u['styles']
                                                                  as List<
                                                                    dynamic
                                                                  >?) ==
                                                              null ||
                                                          (u['styles']
                                                                  as List<
                                                                    dynamic
                                                                  >?)!
                                                              .isEmpty)
                                                      ? 'None'
                                                      : (u['styles']
                                                              as List<dynamic>)
                                                          .join(", "),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed:
                                                          () =>
                                                              _showUnfriendConfirmation(
                                                                friendEmail!,
                                                                u['userName'] ??
                                                                    'User',
                                                              ),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red[400],
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Unfriend',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFF86400,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Close',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [],
                                        );
                                      },
                                      transitionBuilder: (
                                        context,
                                        anim1,
                                        anim2,
                                        child,
                                      ) {
                                        return ScaleTransition(
                                          scale: CurvedAnimation(
                                            parent: anim1,
                                            curve: Curves.easeOutBack,
                                          ),
                                          child: FadeTransition(
                                            opacity: anim1,
                                            child: child,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Colors.orange[50]!,
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          12,
                                          12,
                                          18,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: _buildProfileImage(u),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              u['userName'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFFF86400),
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 20),
                                            Flexible(
                                              child: Text(
                                                ((u['styles']
                                                                as List<
                                                                  dynamic
                                                                >?) ==
                                                            null ||
                                                        (u['styles']
                                                                as List<
                                                                  dynamic
                                                                >?)!
                                                            .isEmpty)
                                                    ? 'None'
                                                    : (u['styles']
                                                            as List<dynamic>)
                                                        .join(", "),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFF86400),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Color(0xFFF97419),
            onPressed: () {
              final emailController = TextEditingController();
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Add Friend',
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, anim1, anim2) {
                  return AlertDialog(
                    title: const Text('Add Friend'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "You can add friends with their email address.",
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter the email of your friend',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black, // orange
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFF97419), // orange
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (value) async {
                            final enteredEmail = value.trim();
                            final currentUserEmail = user.email;
                            await _handleAddFriend(
                              context,
                              enteredEmail,
                              currentUserEmail,
                            );
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final enteredEmail = emailController.text.trim();
                          final currentUserEmail = user.email;
                          await _handleAddFriend(
                            context,
                            enteredEmail,
                            currentUserEmail,
                          );
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: anim1,
                      curve: Curves.easeOutBack,
                    ),
                    child: FadeTransition(opacity: anim1, child: child),
                  );
                },
              );
            },
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text(
              'Add Friend',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddFriend(
    BuildContext context,
    String enteredEmail,
    String? currentUserEmail,
  ) async {
    if (enteredEmail == currentUserEmail) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can't add yourself as a friend.")),
        );
      }
      return;
    }
    // Fetch current user's friends from Firestore
    final user = Provider.of<AuthProvider>(context, listen: false).userObj;
    if (user == null) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showCustomSnackbar(context, 'User not found.');
      }
      return;
    }
    final userDoc =
        await FirebaseFirestore.instance
            .collection('appusers')
            .doc(user.uid)
            .get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final List<dynamic> friends =
        userData != null && userData['friends'] != null
            ? List.from(userData['friends'])
            : [];
    if (friends.contains(enteredEmail)) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showCustomSnackbar(context, 'User is already your friend.');
      }
      return;
    }
    final query =
        await FirebaseFirestore.instance
            .collection('appusers')
            .where('email', isEqualTo: enteredEmail)
            .limit(1)
            .get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      List<dynamic> pendingRequests = data['pendingRequests'] ?? [];
      if (!pendingRequests.contains(currentUserEmail)) {
        pendingRequests.add(currentUserEmail);
        await doc.reference.update({'pendingRequests': pendingRequests});
        if (context.mounted) {
          Navigator.of(context).pop();
          showCustomSnackbar(context, 'Friend request sent!');
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
          showCustomSnackbar(
            context,
            'You have already sent a request to this user.',
          );
        }
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
        showCustomSnackbar(context, 'User not found.');
      }
    }
  }

  Future<void> _handleUnfriend(String friendEmail) async {
    final user = Provider.of<AuthProvider>(context, listen: false).userObj;
    if (user == null) return;

    try {
      // Get current user's document
      final userDoc =
          await FirebaseFirestore.instance
              .collection('appusers')
              .doc(user.uid)
              .get();

      // Get friend's document
      final friendQuery =
          await FirebaseFirestore.instance
              .collection('appusers')
              .where('email', isEqualTo: friendEmail)
              .limit(1)
              .get();

      if (friendQuery.docs.isEmpty) {
        showCustomSnackbar(context, 'Friend not found.');
        return;
      }

      final friendDoc = friendQuery.docs.first.reference;
      final friendData = friendQuery.docs.first.data();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Update current user's friends list
      final userFriends = List<String>.from(userData['friends'] ?? []);
      userFriends.remove(friendEmail);
      await userDoc.reference.update({'friends': userFriends});

      // Update friend's friends list
      final friendFriends = List<String>.from(friendData['friends'] ?? []);
      friendFriends.remove(user.email);
      await friendDoc.update({'friends': friendFriends});

      if (context.mounted) {
        Navigator.of(context).pop(); // Close the friend details dialog
        showCustomSnackbar(context, 'Friend removed successfully.');
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackbar(context, 'Error removing friend: $e');
      }
    }
  }

  Future<void> _showUnfriendConfirmation(
    String friendEmail,
    String friendName,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unfriend User'),
          content: Text('Are you sure you want to unfriend @$friendName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleUnfriend(friendEmail);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Unfriend'),
            ),
          ],
        );
      },
    );
  }

  void showCustomSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // reused function for building profile image

  Widget _buildProfileImage(Map<String, dynamic> user) {
    final profileImageBase64 = user['profileImageBase64'] as String?;
    if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          base64Decode(profileImageBase64),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF86400),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[100]!, width: 1),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
