import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "Enter apiKey",
          appId: "Enter Appid",
          messagingSenderId: "Enter messagingSenderId",
          projectId: "enter projectId"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData themeM = ThemeData(
      primaryColor: const Color.fromARGB(255, 209, 24, 11),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromARGB(255, 209, 24, 11)),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)));

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      theme: themeM,
      debugShowCheckedModeBanner: false,
    );
  }
}
