import 'package:flutter/material.dart';
import '../screens/home-page/home_page.dart';
import '../screens/travel-page/travel_form.dart';
import '../screens/profle-page/profile_page.dart';
import '../screens/similar_people/similar_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF86400);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.people_alt_rounded,
                color: orange,
              ),
              onPressed: () => onTabSelected(0),
            ),

            IconButton(
              icon: Icon(
                Icons.person_search,
                color: orange,
              ),
              onPressed: () => onTabSelected(3),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF86400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () => onTabSelected(1),
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.notifications,
                color: orange,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: orange,
              ),
              onPressed: () => onTabSelected(2),
            ),

            
            
          ],
        ),
      ),
    );
  }
}