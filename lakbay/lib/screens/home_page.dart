import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as local_auth;
import 'starting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Enables the default drawer icon
        title: const Text('Lakbay Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<local_auth.AuthProvider>().signOut();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => StartingPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // Add the DrawerWidget
      drawer: DrawerWidget(user: currentUser),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.travel_explore,
              size: 100,
              color: Color(0xFF5F7CF6),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Lakbay!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Plan your next journey with us.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
