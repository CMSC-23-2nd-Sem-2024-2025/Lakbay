import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylePage extends StatefulWidget {
  const StylePage({super.key});

  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {

  List<String> selectedStyle = [];

  final styles = [
    'Solo Travel',
    'Group Travel',
    'Luxury',
    'Study Tours',
    'Backpacking',
    'Roadtrip',
    'Romantic Getaway',
    'Budget Friendly',
    'Pet-friendly',
    'Extreme Travel',
  ];
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
                "Your Styles.",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // sub banner
              const Text(
                "Highlight how you love to travel by choosing your preferred travel styles.",
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
                  itemCount: styles.length,
                  itemBuilder: (context, index) {

                    // get specific interest on the interests index
                    final style = styles[index];

                    // return the selectable choice chip
                    return ChoiceChip(

                      // apply shadow since may shadow sa figma
                      elevation: 1,
                      shadowColor: Colors.black,
                      showCheckmark: false,

                      // DO NOT REMOVE THIS. pag tinanggal tong center di magpapantay yung buttons
                      label: Center(
                        child: Text(
                          style,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      selected: selectedStyle.contains(style),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              // add and remove on the selectedInterest list dynamically
                              ? selectedStyle.add(style)
                              : selectedStyle.remove(style);
                          print(styles); // this is for debugging only
                        });
                      },

                      // curve
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),

                      // ito yung kulay pag selected yung chip
                      selectedColor: Colors.black,

                      // pag di selected
                      backgroundColor: Colors.white,

                      // edit label
                      labelStyle: TextStyle(
                        color:
                            selectedStyle.contains(style)
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