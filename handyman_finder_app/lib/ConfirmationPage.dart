import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ConfirmationPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> requestData;
  final String username;

  const ConfirmationPage(
      {required this.requestData, required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    LatLng pinLocation = LatLng(
        requestData["location"].latitude, requestData["location"].longitude);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation of Service Request")),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Problem: ${requestData['title']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 12.0),
            Text(
              "Description: ${requestData['description']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12.0),
            Text("Service requested by: ${requestData['author']}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12.0),
            Text(
                "Service requested on: ${returnDateinString(requestData["date_time"])}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12.0),
            Text("Address: ${requestData["address"]}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12.0),
            SizedBox(
                height: 400,
                width: 1400,
                child: Card(
                    child: FlutterMap(
                  options: MapOptions(
                    center: pinLocation,
                    zoom: 14.0,
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
                            point: pinLocation,
                            builder: (context) => IconButton(
                                  icon: const Icon(Icons.location_on),
                                  onPressed: () {},
                                  color: Colors.red,
                                ))
                      ],
                    )
                  ],
                ))),
            const Divider(),
            Text("Request accepted by: ${requestData['handyman']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 12.0),
            Text(
              "Type of service: ${requestData['service']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12.0),
            Text("Price per hour: ${requestData['price_per_hour']}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12.0),
            Text("Other fee: ${requestData["fee"]}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12.0),
            Text("Description of fee: ${requestData["description_of_fee"]}",
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 20.0),
            if (requestData['author'] == username &&
                requestData['handyman'] != null &&
                requestData['accepted'] == false)
              Center(
                  child: ElevatedButton(
                      onPressed: () {
                        AcceptRequest(requestData.id, context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 47, 45, 45)),
                      child: const Text("Accept price"))),
            const SizedBox(height: 5.0),
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      updateRequestStatus(requestData.id, context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
                    child: const Text("Decline")))
          ])),
    );
  }

  Future<void> updateRequestStatus(
      String requestID, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("requests")
          .doc(requestID)
          .update({
        "accepted": false,
        "price_per_hour": null,
        "fee": null,
        "description_of_fee": null,
        "handyman": null
      });
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

Future<void> AcceptRequest(String requestID, BuildContext context) async {
  try {
    await FirebaseFirestore.instance
        .collection("requests")
        .doc(requestID)
        .update({
      "accepted": true,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error --> $e",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.red,
    ));
  }
}

String returnDateinString(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
  return formattedDate;
}
