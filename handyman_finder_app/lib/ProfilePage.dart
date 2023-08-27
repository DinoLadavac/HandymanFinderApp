import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'MainPage.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String userId = "";
  LatLng addressLocation = LatLng(45.3271, 14.4422);
  GeoPoint loadedLocation = const GeoPoint(45.3271, 14.4422);
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.username;
    getInfo();
  }

  void getInfo() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: usernameController.text)
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);

    if (userSnapshot.exists) {
      setState(() {
        addressController.text = userSnapshot.get('address');
        loadedLocation = userSnapshot.get('address_location');
        addressLocation =
            LatLng(loadedLocation.latitude, loadedLocation.longitude);
        userId = userSnapshot.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Form(
            key: formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username is required";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Address is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                          height: 400,
                          width: 1400,
                          child: Card(
                              child: FlutterMap(
                            options: MapOptions(
                              center: addressLocation,
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
                                      point: addressLocation,
                                      builder: (context) => IconButton(
                                            icon: const Icon(Icons.location_on),
                                            onPressed: () {},
                                            color: Colors.red,
                                          ))
                                ],
                              )
                            ],
                          ))),
                      Center(
                          child: Column(children: [
                        ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                UpdateInfo(usernameController, userId,
                                    addressController, addressLocation);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 47, 45, 45)),
                            child: const Text("Submit Changes!")),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              ReturnToMain();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 47, 45, 45)),
                            child: const Text("Cancel"))
                      ])),
                    ]))));
  }

  void onMapTapped(LatLng setLocation) {
    setState(() {
      addressLocation = setLocation;
    });
  }

  // ignore: non_constant_identifier_names
  void ReturnToMain() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(username: widget.username)));
  }

  // ignore: non_constant_identifier_names
  Future<void> UpdateInfo(
      TextEditingController usernameController,
      String userId,
      TextEditingController addressController,
      LatLng addressLocation) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': usernameController.text,
        'address': addressController.text,
        'address_location':
            GeoPoint(addressLocation.latitude, addressLocation.longitude),
      });
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(username: widget.username)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error --> $e",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    }
  }
}
