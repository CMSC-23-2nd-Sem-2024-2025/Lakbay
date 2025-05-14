import 'package:flutter/material.dart';
import 'package:lakbay/screens/home_page.dart';

class TravelFormPage extends StatelessWidget {
  const TravelFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFF97419);

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // for back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),

              const SizedBox(height: 40),

              // RichText is used to control the design or style of each word
              // TextSpan allows the user to select and modify the text for changing its font color, style, or size
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),

                  // title of the travel form page
                  children: [
                    TextSpan(text: 'MAKE YOUR '),
                    TextSpan(
                      text: 'TRAVEL\nPLAN ',
                      style: TextStyle(color: orange),
                    ),
                    TextSpan(text: 'AHEAD!'),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              // naming convention for the text field = Travel Name
              //**INPUT VALIDATION */
              _Label('Travel Name'),
              _ShadowedTextField(
                hintText: 'Enter Travel Name',
                icon: Icons.flight_takeoff,
              ),

              const SizedBox(height: 40),

              // naming convention for the text field = Location
              //**INPUT VALIDATION */
              _Label('Location'),
              _ShadowedTextField(
                hintText: 'Enter Location',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 40),

              // naming convention for the text field = Departure Date
              // **IMPLEMENT THE DATE PICKER
              //**INPUT VALIDATION */
              _Label('Departure Date'),
              _ShadowedTextField(
                hintText: 'Enter Departure Date',
                icon: Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 40),

              // naming convention for the text field = Return Date
              // **IMPLEMENT THE TIME PICKER
              //**INPUT VALIDATION */
              _Label('Return Date'),
              _ShadowedTextField(
                hintText: 'Enter Return Date',
                icon: Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 90),

              // for continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(), // sample route
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// for custom lable widget
// reusable widget
// used for displaying name of the field ("Travel Name", "Location")
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}

// for custom shadowed text field widget
// this gives shadow effect to each text field
class _ShadowedTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  const _ShadowedTextField({
    Key? key,
    required this.hintText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),

          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),

        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
