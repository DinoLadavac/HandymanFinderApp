import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'ConfirmationPage.dart';
import 'MainPage.dart';

class HistoryRequestPage extends StatefulWidget {
  final String username;

  const HistoryRequestPage({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryRequestPageState createState() => _HistoryRequestPageState();
}

class _HistoryRequestPageState extends State<HistoryRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Requests'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ReturnToMain();
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('author', isEqualTo: widget.username)
                .orderBy('date_time', descending: true)
                .snapshots(),
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(
                    child: Text("You haven't requested any service yet!"));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index];
                    Timestamp timestamp = request.get('date_time');
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(dateTime);
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ConfirmationPage(requestData: request)));
                        },
                        child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.all(16.0),
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request['service'],
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(249, 167, 3, 3)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(request['title'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(request['description'],
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Date: $formattedDate',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        if (!request['accepted'])
                                          const Text("Pending",
                                              style: TextStyle(
                                                fontSize: 12,
                                              ))
                                        else
                                          Text(
                                              "Accepted by ${request["handyman"]}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 232, 20, 5))),
                                        ElevatedButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('requests')
                                                  .doc(request.id)
                                                  .delete()
                                                  .then((_) {});
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 47, 45, 45)),
                                            child: const Text("Delete request"))
                                      ],
                                    )
                                  ],
                                ))));
                  });
            })));
  }

  // ignore: non_constant_identifier_names
  void ReturnToMain() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(username: widget.username)));
  }
}
