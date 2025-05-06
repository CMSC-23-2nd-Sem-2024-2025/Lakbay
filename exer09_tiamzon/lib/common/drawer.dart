import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/user_details_page.dart';

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
            title: Text('Expenses'),
            onTap: () => Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
          ListTile(
            title: Text('User Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
    );
  }
}
