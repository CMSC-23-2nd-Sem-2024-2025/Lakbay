import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:lakbay/screens/home_page.dart';
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
              
              
              if (ModalRoute.of(context)?.settings.name != '/profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                    settings: RouteSettings(name: '/profile'),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: Text('Your Plans'),
            onTap: () {
              Navigator.pop(context); 
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                    settings: RouteSettings(name: '/home'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}