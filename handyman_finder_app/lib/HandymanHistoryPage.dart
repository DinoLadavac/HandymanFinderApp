// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'ConfirmationPage.dart';
// ignore: depend_on_referenced_packages
import 'login.dart';

class HandymanHistoryPage extends StatelessWidget {
  final String username;

  const HandymanHistoryPage({super.key, required this.username});

  void _handleLogOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("My requests"), actions: [
          const Padding(
              padding: EdgeInsets.only(top: 16.0, right: 16.0),
              child: Text("Logged in as")),
          Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(username,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
              onPressed: () => _handleLogOut(context),
              icon: const Icon(Icons.logout))
        ]),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('handyman', isEqualTo: username)
              .orderBy('date_time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                      "You haven't requested any price on a service yet."));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var requestData = snapshot.data!.docs[index];
                Timestamp timestamp = requestData['date_time'];
                DateTime dateTime = timestamp.toDate();
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateTime);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmationPage(
                                  requestData: requestData,
                                  username: username,
                                )));
                  },
                  child: Card(
                      child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(requestData['service'],
                            style: const TextStyle(
                                color: Color.fromARGB(249, 167, 3, 3),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text(requestData['title'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text(requestData['description'],
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(requestData['author'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        Text(formattedDate,
                            style: const TextStyle(color: Colors.black)),
                        if (requestData['accepted'])
                          const Text("Accepted",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 232, 20, 5)))
                        else
                          Text(
                            "Waiting for ${requestData['author']} to approve",
                          )
                      ],
                    ),
                  )),
                );
              },
            );
          },
        ));
  }
}
