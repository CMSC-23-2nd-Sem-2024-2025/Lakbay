import 'package:flutter/material.dart';
import 'package:lakbay/components/bottomnav.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/profle-page/profile_page.dart';
import 'package:lakbay/screens/similar_people/similar_page.dart';
import 'package:lakbay/screens/travel-page/travel_form.dart';



class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TravelFormPage(),
    ProfilePage(),
    FindSimilar(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}