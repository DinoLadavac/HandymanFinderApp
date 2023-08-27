import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MainPage.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: RegisterForm(),
        ));
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  String username = "";
  String email = "";
  String password = "";
  String confirmpass = "";
  String address = "";
  LatLng selectedLocation = LatLng(45.3271, 14.4422);

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
            child: Column(children: [
          TextFormField(
            decoration: const InputDecoration(labelText: "Enter your username"),
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
            decoration: const InputDecoration(labelText: "Enter your Email"),
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
          TextFormField(
            decoration: const InputDecoration(labelText: "Enter you Address"),
            onChanged: (value) {
              address = value;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
              height: 400,
              width: 1400,
              child: Card(
                  child: FlutterMap(
                      options: MapOptions(
                        center: selectedLocation,
                        zoom: 14.0,
                        onTap: onMapTapped,
                      ),
                      layers: [
                    TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                            width: 40.0,
                            height: 40.0,
                            point: selectedLocation,
                            builder: (context) => IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.location_on),
                                color: Colors.red))
                      ],
                    )
                  ]))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                registerUser(username, email, password, address,
                    selectedLocation, context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Register"),
          )
        ])));
  }

  void onMapTapped(LatLng setLocation) {
    setState(() {
      selectedLocation = setLocation;
    });
  }

  Future<void> registerUser(String username, String email, String password,
      String address, LatLng selectedLocation, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'address': address,
        'address_location':
            GeoPoint(selectedLocation.latitude, selectedLocation.longitude)
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(username: username)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while registrering --> $e",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    }
  }
}
