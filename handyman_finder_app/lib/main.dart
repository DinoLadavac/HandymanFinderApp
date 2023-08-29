import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyADW311E5Byw5an3kPBT9c2gTVdKF3sKSA",
          appId: "1:828100715380:web:8e90937dea7e19fa79c221",
          messagingSenderId: "828100715380",
          projectId: "handymanfinderapp-dlzr"));
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
