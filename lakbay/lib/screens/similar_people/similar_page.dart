import 'package:flutter/material.dart';
import 'package:lakbay/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:convert';

class FindSimilar extends StatefulWidget {
  const FindSimilar({super.key});

  @override
  State<FindSimilar> createState() => _FindSimilarState();
}

class _FindSimilarState extends State<FindSimilar> {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final user = authProvider.userObj;
    final userDetails = authProvider.userDetails;

    print('DEBUG: user = $user');
    print('DEBUG: userDetails = $userDetails');
    if (isLoading || user == null || userDetails == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 35, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Similar',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: (Color(0xFFF97419)),
                ),
              ),
              Text(
                'Discover people!',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: planProvider.streamSimilarUsers(
                    currentUserId: user.uid,
                    interests: List<String>.from(
                      userDetails['interests'] ?? [],
                    ),
                    styles: List<String>.from(userDetails['styles'] ?? []),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF86400)),
                      ));
                    }
                    final similarUsers = snapshot.data!;
                    if (similarUsers.isEmpty) {
                      return const Center(
                        child: Text('No similar users found.'),
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
                      itemCount: similarUsers.length,
                      itemBuilder: (context, index) {
                        final u = similarUsers[index];
                        final currentUserInterests = Set<String>.from(
                          userDetails['interests'] ?? [],
                        );
                        final otherUserInterests = Set<String>.from(
                          u['interests'] ?? [],
                        );
                        final currentUserStyles = Set<String>.from(
                          userDetails['styles'] ?? [],
                        );
                        final otherUserStyles = Set<String>.from(
                          u['styles'] ?? [],
                        );

                        final matchingInterests =
                            currentUserInterests
                                .intersection(otherUserInterests)
                                .toList();
                        final matchingStyles =
                            currentUserStyles
                                .intersection(otherUserStyles)
                                .toList();

                        String matchText = '';
                        if (matchingInterests.isNotEmpty) {
                          matchText += matchingInterests.join(", ");
                        }
                        if (matchingStyles.isNotEmpty) {
                          if (matchText.isNotEmpty) matchText += ', ';
                          matchText += matchingStyles.join(", ");
                        }

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: SizedBox(
                                    width: 300,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(child: _buildProfileImage(u)),
                                        const SizedBox(height: 16),

                                        Center(
                                          child: Text(
                                            '@${u['userName']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        Text(
                                          'Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        TextField(
                                          controller: TextEditingController(
                                            text:
                                                '${u['firstName']} ${u['lastName']}',
                                          ),
                                          readOnly: true,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),

                                        SizedBox(height: 14),

                                        Text(
                                          'Contact info',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextField(
                                          controller: TextEditingController(
                                            text: u['email'] ?? '',
                                          ),
                                          readOnly: true,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),

                                        SizedBox(height: 14),

                                        Text(
                                          'Interests',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        TextField(
                                          controller: TextEditingController(
                                            text:
                                                (u['interests']
                                                        as List<dynamic>?)
                                                    ?.join(", ") ??
                                                '',
                                          ),
                                          readOnly: true,
                                          enabled: false,
                                          maxLines: null,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),

                                        SizedBox(height: 14),

                                        Text(
                                          'Styles',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        TextField(
                                          controller: TextEditingController(
                                            text:
                                                (u['styles'] as List<dynamic>?)
                                                    ?.join(", ") ??
                                                '',
                                          ),
                                          readOnly: true,
                                          enabled: false,
                                          maxLines: null,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'Back',
                                        style: TextStyle(color: Colors.black),
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildProfileImage(u),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${u['userName'] ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: Text(
                                      matchText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
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
    );
  }
}
