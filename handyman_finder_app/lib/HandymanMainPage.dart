// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handyman_finder_app/requestDetailPage.dart';
// ignore: depend_on_referenced_packages
import 'login.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class HandymanMainPage extends StatelessWidget {
  final String username;

  const HandymanMainPage({required this.username, super.key});

  void _handleLogOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<List<String>> getServiceForHandyman(
      String username, BuildContext context) async {
    List<String> services = [];
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('handyman')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.size > 0) {
        var handymanData = querySnapshot.docs.first;
        if (handymanData.exists) {
          services = List<String>.from(handymanData['services']);
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error --> $error",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ));
    }

    return services;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Handyman Locator"),
        actions: [
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('accepted', isEqualTo: false)
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
                      'No requested services yet! Thank you for checking!'));
            }
            return FutureBuilder<List<String>>(
              future: getServiceForHandyman(username, context),
              builder: (context, servicesSnapshot) {
                if (servicesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (servicesSnapshot.hasError) {
                  return Center(
                      child: Text("Error: ${servicesSnapshot.error}"));
                }

                List<String> services = servicesSnapshot.data ?? [];
                var filterRequest = snapshot.data!.docs
                    .where((requestData) => services
                        .any((service) => service == requestData["service"]))
                    .toList();

                if (filterRequest.isEmpty) {
                  return const Center(
                      child: Text("Sorry, No request for your services yet.."));
                }
                return ListView.builder(
                  itemCount: filterRequest.length,
                  itemBuilder: (context, index) {
                    var requestData = filterRequest[index];
                    Timestamp timestamp = requestData['date_time'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(dateTime);
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RequestDetailPage(
                                      requestData: requestData,
                                      username: username)));
                        },
                        child: Card(
                            child: ListTile(
                                title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(requestData["service"],
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  249, 167, 3, 3),
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4.0),
                                      Text(requestData["title"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4.0),
                                      Text(requestData['description'],
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ]),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(requestData['author'],
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    Text(formattedDate,
                                        style: const TextStyle(
                                            color: Colors.black))
                                  ],
                                ))));
                  },
                );
              },
            );
          }),
    );
  }
}
