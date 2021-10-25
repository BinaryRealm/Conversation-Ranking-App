import 'package:chat_app/auth_class.dart';
import 'package:chat_app/driver.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';

class UserPage extends StatefulWidget {
  final String uid;
  const UserPage({Key? key, required String this.uid}) : super(key: key);
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
            future: _db.collection("users").doc(widget.uid).get(),
            builder:
                (context, AsyncSnapshot<DocumentSnapshot> documentSnapshot) {
              if (documentSnapshot.hasData) {
                var d = documentSnapshot.data!;
                return ListView(
                  children: [
                    Text("${d.get('first_name')} ${d.get('last_name')}",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    Image.network(
                      d.get("picture_url"),
                    ),
                    Card(
                        child: ListTile(
                            title: Text("About ${d.get('first_name')}:",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: Text("${d.get('bio')}"))),
                    Card(
                        child: ListTile(
                            title: const Text("Average Conversation Rating:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: StreamBuilder<QuerySnapshot>(
                                stream: _db
                                    .collection("users")
                                    .doc(d.id)
                                    .collection("ratings")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Text("Loading..."),
                                    );
                                  } else {
                                    num sum = 0;
                                    num count = 0;
                                    for (var i in snapshot.data!.docs) {
                                      sum += i.get("rating");
                                      count++;
                                    }
                                    num average = sum / count;
                                    return Text(
                                        average.isNaN ? "Unrated" : "$average");
                                  }
                                }))),
                    Card(
                        child: ListTile(
                      title: const Text("Hometown:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Text("${d.get("hometown")}"),
                    )),
                    Card(
                        child: ListTile(
                      title: const Text("Age:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "${DateTime.now().year - int.parse(d.get("year"))} years old"),
                    )),
                  ],
                );
              } else {
                return const SomethingWentWrong();
              }
            }),
        appBar: AppBar(
          title: const Text("User Info"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Log Out',
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildLogoutDialog(context),
                );
              },
              tooltip: 'Log Out',
              icon: const Icon(Icons.logout),
            ),
          ],
        ));
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return AlertDialog(
        title: const Text("Do you want to log out?"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              OutlinedButton(
                onPressed: () {
                  _signOut(context);
                },
                child: const Text('Log out'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              )
            ]));
  }

  void _signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await FireAuthClass.logout();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }
}
