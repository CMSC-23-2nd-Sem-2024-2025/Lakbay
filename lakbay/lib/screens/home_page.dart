import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'starting_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    // final userDetails = authProvider.userDetails;

    // if (userDetails != null) {
    //   print("First Name: ${userDetails['firstName']}");
    //   print("Last Name: ${userDetails['lastName']}");
    // } else {
    //   print("User details are null");
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Enables the default drawer icon
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

      drawer: DrawerWidget(user: user),

      body: 
      
      // userDetails == null
      //   ? const Center(child: CircularProgressIndicator())
      //   : 
        SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Hi, ${userDetails['firstName']} ${userDetails['lastName']}",
                //   style: const TextStyle(fontSize: 18),
                // ),
              ],
            ),
          ),
    );
  }
}
