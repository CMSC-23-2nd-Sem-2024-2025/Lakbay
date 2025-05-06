import 'package:exer08_tiamzon/screens/auth_init_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/expenses_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => ExpenseListProvider()),
        ), // manages expenses related operations
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
      title: 'Expense Tracker',
      theme: ThemeData(
        fontFamily: 'Poppins', // Set Poppins as the default font
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home:
          const AuthenticationInitPage(), // set the default page (route) to SignIn/SignUp page
    );
  }
}
