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
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF97419),
                    ),
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
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final u =
                                    docs[index].data() as Map<String, dynamic>;
                                final friendEmail = u['email'] as String?;
                                return SizedBox(
                                  height: 220, // Fixed height for card
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: SizedBox(
                                                    width: 300,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Center(
                                                          child:
                                                              _buildProfileImage(
                                                                u,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        Center(
                                                          child: Text(
                                                            '@${u['userName']}',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  fontSize: 15,
                                                                ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          'Name',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        TextField(
                                                          controller:
                                                              TextEditingController(
                                                                text:
                                                                    '${u['firstName']} ${u['lastName']}',
                                                              ),
                                                          readOnly: true,
                                                          enabled: false,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                          decoration:
                                                              const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          'Contact info',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        TextField(
                                                          controller:
                                                              TextEditingController(
                                                                text:
                                                                    u['email'] ??
                                                                    '',
                                                              ),
                                                          readOnly: true,
                                                          enabled: false,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                          decoration:
                                                              const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          'Interests',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        TextField(
                                                          controller: TextEditingController(
                                                            text:
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
                                                                            as List<
                                                                              dynamic
                                                                            >)
                                                                        .join(
                                                                          ", ",
                                                                        ),
                                                          ),
                                                          readOnly: true,
                                                          enabled: false,
                                                          maxLines: null,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                          decoration:
                                                              const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          'Styles',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        TextField(
                                                          controller: TextEditingController(
                                                            text:
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
                                                                            as List<
                                                                              dynamic
                                                                            >)
                                                                        .join(
                                                                          ", ",
                                                                        ),
                                                          ),
                                                          readOnly: true,
                                                          enabled: false,
                                                          maxLines: null,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                          decoration:
                                                              const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(),
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                      child: const Text(
                                                        'Back',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _buildProfileImage(u),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    u['userName'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Flexible(
                                                    child: Text(
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
                                                                  as List<
                                                                    dynamic
                                                                  >)
                                                              .join(", "),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Delete button (top right)
                                      if (friendEmail != null)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Remove Friend',
                                            onPressed: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Remove Friend',
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to remove this friend?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                          child: const Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                // Remove friend from current user's friends
                                                final userDoc =
                                                    FirebaseFirestore.instance
                                                        .collection('appusers')
                                                        .doc(user.uid);
                                                final userFriends =
                                                    List<String>.from(
                                                      (userDetails['friends'] ??
                                                          []),
                                                    );
                                                userFriends.remove(friendEmail);
                                                await userDoc.update({
                                                  'friends': userFriends,
                                                });
                                                // Remove current user from friend's friends
                                                final friendQuery =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('appusers')
                                                        .where(
                                                          'email',
                                                          isEqualTo:
                                                              friendEmail,
                                                        )
                                                        .limit(1)
                                                        .get();
                                                if (friendQuery
                                                    .docs
                                                    .isNotEmpty) {
                                                  final friendDoc =
                                                      friendQuery
                                                          .docs
                                                          .first
                                                          .reference;
                                                  final friendData =
                                                      friendQuery.docs.first
                                                          .data();
                                                  final friendFriends =
                                                      List<String>.from(
                                                        friendData['friends'] ??
                                                            [],
                                                      );
                                                  if (user.email != null) {
                                                    friendFriends.remove(
                                                      user.email,
                                                    );
                                                  }
                                                  await friendDoc.update({
                                                    'friends': friendFriends,
                                                  });
                                                }
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Friend removed successfully.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                    ],
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

          floatingActionButton: FloatingActionButton(
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
            child: const Icon(Icons.person_add, color: Colors.white),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Friend request sent!')));
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have already sent a request to this user.'),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not found.')));
      }
    }
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
}
