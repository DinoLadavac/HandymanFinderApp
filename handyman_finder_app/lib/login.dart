import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handyman_finder_app/registerUser.dart';
import 'registerHandyman.dart';
import 'MainPage.dart';
import 'HandymanMainPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Log in")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoginForm(context: context),
        ));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({required this.context, super.key});
  final BuildContext context;

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final key = GlobalKey<FormState>();
  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Enter Email"),
          validator: (value) {
            if (value!.isEmpty) {
              return "Email required!";
            }
            return null;
          },
          onChanged: (value) {
            email = value;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Enter Password"),
          obscureText: true,
          validator: (value) {
            if (value!.isEmpty) {
              return "Password required!";
            }
            return null;
          },
          onChanged: (value) {
            password = value;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (key.currentState!.validate()) {
              loginUser(email, password, context);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
          child: const Text("Log in"),
        ),
        const SizedBox(height: 20),
        const Text("Not a member? Try registering first!"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationPage()));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
          child: const Text("Register"),
        ),
        const SizedBox(height: 20),
        const Text("Want to register your workspace?"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HandymanRegistrationPage()));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
          child: const Text("Register as Handyman"),
        ),
      ]),
    );
  }
}

Future<void> loginUser(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (userCredential.user != null) {
      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        String username = userDoc.get("username");
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(username: username)));
      }

      DocumentSnapshot handymanDoc = await FirebaseFirestore.instance
          .collection('handyman')
          .doc(userId)
          .get();
      if (handymanDoc.exists) {
        String username = handymanDoc.get("username");
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HandymanMainPage(username: username)));
      }
    }
  } catch (err) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error while logging in --> $err",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.red,
    ));
  }
}
