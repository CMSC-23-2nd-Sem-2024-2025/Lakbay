import 'package:flutter/material.dart';
import 'package:lakbay/common/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'starting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserDetails().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userObj;
    final details = authProvider.userDetails;
    return Scaffold(

      body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null || details == null
              ? const Center(child: Text("No travel plans yet"))
              :
              SingleChildScrollView(),
              
    );
  }
}