import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handyman_finder_app/HandymanMainPage.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class RequestDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> requestData;
  final String username;

  const RequestDetailPage(
      {required this.requestData, required this.username, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RequestDetailPageState createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final TextEditingController pph = TextEditingController();
  final TextEditingController fee = TextEditingController();
  final TextEditingController descOfFee = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Request Details")),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Service: ${widget.requestData["service"]}",
                    style: const TextStyle(
                        color: Color.fromARGB(249, 167, 3, 3), fontSize: 14)),
                const SizedBox(height: 8.0),
                Text("Title: ${widget.requestData['title']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8.0),
                Text(
                  "Description: ${widget.requestData['description']}",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8.0),
                Text("Author: ${widget.requestData['author']}",
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8.0),
                Text(
                    "Date: ${returnDateinString(widget.requestData["date_time"])}",
                    style: const TextStyle(fontSize: 12)),
                const Divider(),
                TextFormField(
                    controller: pph,
                    decoration:
                        const InputDecoration(labelText: "Price Per Hour")),
                TextFormField(
                    controller: fee,
                    decoration: const InputDecoration(labelText: "Other fee?")),
                TextFormField(
                    controller: descOfFee,
                    decoration: const InputDecoration(
                        labelText: "Description of other fee")),
                const SizedBox(height: 8.0),
                Center(
                    child: Column(children: [
                  ElevatedButton(
                      onPressed: () {
                        updateRequest(
                            context, pph, fee, descOfFee, widget.username);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HandymanMainPage(
                                      username: widget.username,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 47, 45, 45)),
                      child: const Text("Submit price")),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 47, 45, 45)),
                      child: const Text("Cancel")),
                ]))
              ],
            )));
  }

  void updateRequest(
      BuildContext context,
      TextEditingController pph,
      TextEditingController fee,
      TextEditingController desc,
      String username) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestData.id)
          .update({
        'price_per_hour': pph.text,
        'fee': fee.text,
        'description_of_fee': desc.text,
        'handyman': username
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error --> $error",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    }
  }
}

String returnDateinString(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
  return formattedDate;
}
