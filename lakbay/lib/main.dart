// import 'package:flutter/material.dart';
// import 'screens/login_page.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'screens/login_details.dart';
// import 'screens/signup_details.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SignupDetails(), // run the login page
//       theme: ThemeData(
//         textTheme: GoogleFonts.podkovaTextTheme(
//           Theme.of(context).textTheme, // set the constant font style
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lakbay/screens/auth_init_page.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => AuthProvider()),
        ), // maanages authentication and listtens authentication state changes
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Lakbay',
      theme: ThemeData(
        fontFamily: 'Poppins', // Set Poppins as the default font
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home:
          const AuthenticationInitPage(), // set the default page (route) to SignIn/SignUp page
    );
  }
}
