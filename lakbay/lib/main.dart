import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'screens/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_details.dart';
import 'screens/signup_details.dart';
void main(){
    runApp(const MyApp());
=======
import 'package:firebase_core/firebase_core.dart';
import 'package:lakbay/screens/home-page/starting_page.dart';
import 'package:lakbay/screens/similar_people/similar_page.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/plan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [

        // declare the auth provider and the plan provider using a multiprovider widget
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
        ChangeNotifierProvider(create: ((context) => PlanProvider())),
      ],
      child: const MyApp(),
    ),
  );
>>>>>>> Stashed changes
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SignupDetails(), // run the login page
        theme: ThemeData(
        
        textTheme: GoogleFonts.podkovaTextTheme(
          Theme.of(context).textTheme, // set the constant font style
        ),
      ),

<<<<<<< Updated upstream
=======
        // used a consumer widget to listen to the auth provider and go to either the home page (logged in)
        // or the startinf page (when the userObj is null)
        builder: (context, authProvider, _) {
          if (authProvider.userObj != null) {
            return FindSimilar();
          } else {
            return StartingPage();
          }
        },
      ),
>>>>>>> Stashed changes
    );
  }
}