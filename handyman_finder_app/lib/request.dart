// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'MainPage.dart';

class RequestPage extends StatelessWidget {
  final String service;
  final String username;
  const RequestPage({super.key, required this.service, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Request $service service")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RequestForm(service: service, author: username),
        ));
  }
}

// ignore: must_be_immutable
class RequestForm extends StatefulWidget {
  String service = "";
  String author = "";
  RequestForm({super.key, required this.service, required this.author});

  @override
  // ignore: library_private_types_in_public_api
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";
  LatLng selectedLocation = LatLng(45.3271, 14.4422);
  String address = "";
  GeoPoint loadedLocation = const GeoPoint(45.3271, 14.4422);
  bool NewAddress = false;

  @override
  void initState() {
    super.initState();
    getAddress();
  }

  void getAddress() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.author)
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);

    if (userSnapshot.exists) {
      setState(() {
        address = userSnapshot.get('address');
        loadedLocation = userSnapshot.get('address_location');
        selectedLocation =
            LatLng(loadedLocation.latitude, loadedLocation.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: SingleChildScrollView(
            child: Column(children: [
          TextFormField(
            decoration: const InputDecoration(labelText: "Title / Problem"),
            validator: (value) {
              if (value!.isEmpty) {
                return "Title is required";
              }
              return null;
            },
            onChanged: (value) {
              title = value;
            },
          ),
          TextFormField(
              decoration: const InputDecoration(
                  labelText: "Description of the problem"),
              maxLines: 4,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Description is required";
                }
                return null;
              },
              onChanged: (value) {
                description = value;
              }),
          const SizedBox(height: 20),
          const Text("Where is the service needed? : "),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: Text(address),
            value: !NewAddress,
            onChanged: (value) {
              setState(() {
                NewAddress = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Use new address?"),
            value: NewAddress,
            onChanged: (value) {
              setState(() {
                NewAddress = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          if (NewAddress)
            Column(
              children: [
                TextFormField(
                    decoration:
                        const InputDecoration(labelText: "Enter New Address"),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please uncheck the Checkbox if you don't want to enter a New Address!";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      address = value;
                    }),
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
                                      icon: const Icon(Icons.location_on),
                                      onPressed: () {},
                                      color: Colors.red,
                                    ))
                          ],
                        )
                      ],
                    ))),
              ],
            ),
          ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  storeRequest(title, description, selectedLocation,
                      widget.service, widget.author, address);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
              child: const Text("Submit Request!")),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                ReturnToMain();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
              child: const Text("Cancel"))
        ])));
  }

  void onMapTapped(LatLng setLocation) {
    setState(() {
      selectedLocation = setLocation;
    });
  }

  void storeRequest(String title, String description, LatLng location,
      String service, String author, String address) {
    FirebaseFirestore.instance.collection('requests').add({
      'author': author,
      'address': address,
      'title': title,
      'description': description,
      'service': service,
      'location': GeoPoint(location.latitude, location.longitude),
      'date_time': FieldValue.serverTimestamp(),
      'accepted': false,
      'price_per_hour': null,
      'fee': null,
      'description_of_fee': null,
      'handyman': null,
    }).then((value) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(username: widget.author)));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while creating an request --> $error",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    });
  }

  void ReturnToMain() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(username: widget.author)));
  }
}
