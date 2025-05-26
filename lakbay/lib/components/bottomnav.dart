import 'package:flutter/material.dart';

// this is the bottom navigation bar that is used to navigate between the pages

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

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
              // ignore: deprecated_member_use
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
                Icons.home,
                color: selectedIndex == 0 ? orange : Colors.grey,
              ),
              onPressed: () => onTabSelected(0),
            ),
            IconButton(
              icon: Icon(
                Icons.person_search,
                color: selectedIndex == 3 ? orange : Colors.grey,
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
                Icons.group,
                color: selectedIndex == 4 ? orange : Colors.grey,
              ),
              onPressed: () => onTabSelected(4),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: selectedIndex == 2 ? orange : Colors.grey,
              ),
              onPressed: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}