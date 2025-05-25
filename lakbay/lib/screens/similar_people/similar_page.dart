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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFF86400)),
          ),
        ),
      );
    }

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
                    'Find Similar',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: (Color(0xFFF97419)),
                    ),
                  ),
                  Image.asset('assets/or.png', height: 50),
                ],
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
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xFFF86400)),
                        ),
                      );
                    }
                    final similarUsers = snapshot.data!;
                    if (similarUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          'No similar users found.',
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
                            childAspectRatio: 0.72,
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
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Similar User Details',
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (context, anim1, anim2) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
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
                                        ),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                            '@${u['userName']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                          (u['interests'] as List<dynamic>?)
                                                  ?.join(", ") ??
                                              'None',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildDetailSection(
                                          'Travel Styles',
                                          (u['styles'] as List<dynamic>?)?.join(
                                                ", ",
                                              ) ??
                                              'None',
                                        ),
                                        const SizedBox(height: 24),
                                        Center(
                                          child: TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            style: TextButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFF86400,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Close',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                  colors: [Colors.white, Colors.orange[50]!],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: _buildProfileImage(u),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${u['userName'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFF86400),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        matchText,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFF86400),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
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
                ),
              ),
            ],
          ),
        ),
      ),
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
