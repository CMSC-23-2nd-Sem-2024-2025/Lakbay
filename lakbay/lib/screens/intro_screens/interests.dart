import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestsPage extends StatefulWidget {
  final Function(List<String>) onInterestsSelected;

  const InterestsPage({super.key, required this.onInterestsSelected});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // create instance of string to store the selected interest during set state
  List<String> selectedInterest = [];

  // added list of interests

  final interests = [
    'Hiking and Trekking',
    'Photography',
    'Art & Museums',
    'Cultures & Religions',
    'Nature & Wildlife',
    'Shopping',
    'Food & Local Cuisine',
    'Nightlife',
    'Festivals',
    'Fitness & Wellness',
  ];

  List<String> getInterests() {
    return selectedInterest;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          // set padding
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),

          // set column to place the widgets
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),

              // banner
              Text(
                "Your Interests.",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // sub banner
              const Text(
                "Pick a few travel interests to share what excites you most about exploring the world.",
              ),
              const SizedBox(height: 30),

              // make the gridview expanded
              Expanded(
                child: GridView.builder(
                  // disable scrolling since gridbuilder is scrollable in nature
                  physics: NeverScrollableScrollPhysics(),

                  // set specific number of rows per column
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 30,
                    childAspectRatio: 3.5,
                  ),

                  // set item count dynamically on interests list
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    // get specific interest on the interests index
                    final interest = interests[index];

                    // return the selectable choice chip
                    return ChoiceChip(
                      elevation: 1,
                      shadowColor: Colors.black,
                      showCheckmark: false,
                      label: Center(
                        child: Text(
                        interest,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 14),
                      ),
                      ),
                      selected: selectedInterest.contains(interest),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? selectedInterest.add(interest)
                              : selectedInterest.remove(interest);
                          

                          widget.onInterestsSelected(selectedInterest);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color:
                            selectedInterest.contains(interest)
                                ? Colors.white
                                : Colors.black,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
