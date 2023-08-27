// ignore: file_names
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'handymanMainPage.dart';

class HandymanRegistrationPage extends StatelessWidget {
  const HandymanRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Register as Handyman")),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: HandymanRegisterForm(),
        ));
  }
}

class HandymanRegisterForm extends StatefulWidget {
  const HandymanRegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HandymanRegisterFormState createState() => _HandymanRegisterFormState();
}

class _HandymanRegisterFormState extends State<HandymanRegisterForm> {
  final formKey = GlobalKey<FormState>();
  String username = "";
  String email = "";
  String password = "";
  String confirmpass = "";
  String industry = "";
  List<String> availableServices = [
    "Plumber",
    "Electrician",
    "Ceramist",
    "Locksmith",
    "Painter",
    "Appliance Technician",
    "Carpenter"
  ];
  List<String> selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
            child: Column(children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Enter your Industry/Workspace name"),
            validator: (value) {
              if (value!.isEmpty) {
                return "Required Industry/Workspace!";
              }
              return null;
            },
            onChanged: (value) {
              industry = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Enter your Workspace's Email"),
            validator: (value) {
              if (value!.isEmpty) {
                return "Required Email!";
              }
              return null;
            },
            onChanged: (value) {
              email = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Enter your Username"),
            validator: (value) {
              if (value!.isEmpty) {
                return "Required Username!";
              }
              return null;
            },
            onChanged: (value) {
              username = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Required Password!";
              }
              return null;
            },
            onChanged: (value) {
              password = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Confirm Password"),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please confirm your password!";
              }
              if (value != password) {
                return "Password must match!";
              }
              return null;
            },
            onChanged: (value) {
              confirmpass = value;
            },
          ),
          const SizedBox(height: 20),
          Column(
            children: availableServices.map((services) {
              return CheckboxListTile(
                title: Text(services),
                value: selectedServices.contains(services),
                onChanged: (bool? value) {
                  setState(() {
                    if (value!) {
                      selectedServices.add(services);
                    } else {
                      selectedServices.remove(services);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                registerHandyman(industry, email, username, password,
                    selectedServices, context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Register as Handyman"),
          ),
        ])));
  }
}

Future<void> registerHandyman(String industry, String email, String username,
    String password, List<String> services, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    String handymanId = userCredential.user!.uid;

    await FirebaseFirestore.instance
        .collection('handyman')
        .doc(handymanId)
        .set({
      'industry': industry,
      'industry_email': email,
      'username': username,
      'services': services,
    });
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HandymanMainPage(username: username)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error while registrering --> $e",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    ));
  }
}
