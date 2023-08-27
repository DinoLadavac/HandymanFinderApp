// ignore: file_names
import 'package:flutter/material.dart';
import 'package:handyman_finder_app/HistoryRequests.dart';
import 'login.dart';
// ignore: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'request.dart';
import 'ProfilePage.dart';

class MainPage extends StatelessWidget {
  final String username;

  const MainPage({required this.username, super.key});

  void _handleLogOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Handyman locator"),
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
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "What services do you need?",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Material(
              child: ElevatedButton(
            onPressed: () => navigateToRequest(context, "Plumber", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Plumber", style: TextStyle(fontSize: 20)),
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                navigateToRequest(context, "Electrician", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Electrician", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => navigateToRequest(context, "Ceramist", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Ceramist", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => navigateToRequest(context, "Locksmith", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Locksmith", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => navigateToRequest(
              context,
              "Painter",
              username,
            ),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Painter", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                navigateToRequest(context, "Appliance Technician", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Appliance Technician",
                style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => navigateToRequest(context, "Carpenter", username),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: const Color.fromARGB(255, 47, 45, 45)),
            child: const Text("Carpenter", style: TextStyle(fontSize: 20)),
          ),
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          color: const Color.fromARGB(255, 47, 45, 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(username: username)));
                  },
                  icon: const Icon(Icons.person, color: Colors.white)),
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HistoryRequestPage(username: username)));
                  },
                  icon: const Icon(Icons.history, color: Colors.white))
            ],
          )),
    );
  }
}

void navigateToRequest(BuildContext context, String service, String username) {
  {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => RequestPage(
                  service: service,
                  username: username,
                )));
  }
}
