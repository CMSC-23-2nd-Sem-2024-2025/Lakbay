import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/components/bottomnav.dart';
import 'package:lakbay/screens/home-page/home_page.dart';
import 'package:lakbay/screens/profle-page/profile_page.dart';
import 'package:lakbay/screens/similar_people/friends_page.dart';
import 'package:lakbay/screens/similar_people/similar_page.dart';
import 'package:lakbay/screens/travel-page/travel_form.dart';


// we made a custom navigation bar that is used to navigate between the pages
class MainScaffold extends StatefulWidget {
  // this int is shared accross the app to notify changes in the navigation bar
  static final ValueNotifier<int> navIndexNotifier = ValueNotifier<int>(0);
  const MainScaffold({super.key});
  

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
  
}

class _MainScaffoldState extends State<MainScaffold> {
  
  // now this fetches the value of the global int from the notifier
  int _selectedIndex = 0;
  
  final PageController _pageController = PageController();

  // list of screens that are used for navigation
  final List<Widget> _pages = [
    HomePage(),
    TravelFormPage(),
    ProfilePage(),
    FindSimilar(),
    FriendsPage(),
  ];



  @override
  void initState() {
  super.initState();
  MainScaffold.navIndexNotifier.addListener(() {

    // runs once to add a listener to the notifier and will run everytime the notifier changes
    setState(() {
      _selectedIndex = MainScaffold.navIndexNotifier.value;
    });
  });
}

  // dispose of the page controller when the screen is disposed
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // wrap it in a transition 
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        // this is the page that is currently being displayed
        child: _pages[_selectedIndex],
      ),

      // this is the bottom nav bar that is used to navigate between pages
      bottomNavigationBar: CustomBottomNav(

        // gets the current index
        selectedIndex: _selectedIndex,

        // sets the state of the selected index
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}