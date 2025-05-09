import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:lakbay/screens/profile_page.dart';

class DrawerWidget extends StatefulWidget {
  final User? user;
  const DrawerWidget({super.key, required this.user});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text(widget.user!.email!)),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ), // navigate to profile page when its clicked
              );
            },
          ),
        ],
      ),
    );
  }
}
