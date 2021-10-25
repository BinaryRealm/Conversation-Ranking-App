import 'package:chat_app/auth_class.dart';
import 'package:chat_app/driver.dart';
import 'package:chat_app/views/user_view.dart';
import 'package:chat_app/views/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage /*extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);*/
    extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  String _title = "Users";
  String _search_text = "";
  String firstName = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _title = "Users";
      } else if (_selectedIndex == 1) {
        _title = "Search";
      } else if (_selectedIndex == 2) {
        _title = "Conversations";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Conversations',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: _selectedIndex == 0
            ? StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection("users")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("Loading..."),
                    );
                  } else {
                    return ListView(
                        //scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((e) {
                          if (e.id.toString().length == 28) {
                            return Card(
                                child: ListTile(
                                    leading:
                                        Image.network(e.get("picture_url")),
                                    title: Text(e.get("first_name")),
                                    subtitle: Text(
                                        "Joined: ${e.get("timestamp").toDate().month}/${e.get("timestamp").toDate().day}/${e.get("timestamp").toDate().year} ${e.get("timestamp").toDate().hour}:${e.get("timestamp").toDate().minute}"),
                                    trailing: OutlinedButton(
                                        child: const Icon(Icons.message),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (con) => ChatPage(
                                                      uid: e.id,
                                                      name:
                                                          "${e.get("first_name")} ${e.get("last_name")}")));
                                        }),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (con) =>
                                                  UserPage(uid: e.id)));
                                    }));
                          } else {
                            return Container();
                          }
                        }).toList());
                  }
                })
            : _selectedIndex == 1
                ? Column(
                    children: <Widget>[
                      const SizedBox(height: 5.0),
                      TextFormField(
                        autocorrect: false,
                        onChanged: (string) {
                          setState(() {
                            _search_text = string;
                          });
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            hintText: 'Search Users'),
                      ),
                      _search_text != ""
                          ? StreamBuilder<QuerySnapshot>(
                              stream: _db
                                  .collection("users")
                                  .where("first_name",
                                      isGreaterThanOrEqualTo: _search_text)
                                  .where("first_name",
                                      isLessThanOrEqualTo:
                                          _search_text + '\uf8ff')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: Text("Loading..."),
                                  );
                                } else {
                                  return ListView(
                                      //scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      children: snapshot.data!.docs.map((e) {
                                        return Card(
                                            child: ListTile(
                                                leading: Image.network(
                                                    e.get("picture_url")),
                                                title:
                                                    Text(e.get("first_name")),
                                                subtitle: Text(
                                                    "Joined: ${e.get("timestamp").toDate().month}/${e.get("timestamp").toDate().day}/${e.get("timestamp").toDate().year} ${e.get("timestamp").toDate().hour}:${e.get("timestamp").toDate().minute}"),
                                                trailing: OutlinedButton(
                                                    child: const Icon(
                                                        Icons.message),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (con) =>
                                                                  ChatPage(
                                                                      uid: e.id,
                                                                      name:
                                                                          "${e.get("first_name")} ${e.get("last_name")}")));
                                                    }),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (con) =>
                                                              UserPage(
                                                                  uid: e.id)));
                                                }));
                                      }).toList());
                                }
                              })
                          : Container(),
                    ],
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _db.collection("conversations").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      } else {
                        return ListView(
                            //scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((e) {
                              String? myuid = FireAuthClass.uid;
                              String otherid;
                              String convoid = e.id.toString();
                              if (convoid.length == 57 &&
                                  (convoid.substring(0, 28) == myuid ||
                                      convoid.substring(29, 57) == myuid)) {
                                if (convoid.substring(0, 28) != myuid) {
                                  otherid = convoid.substring(0, 28);
                                } else {
                                  otherid = convoid.substring(29, 57);
                                }
                                return Card(
                                    child: ListTile(
                                        leading: FutureBuilder<
                                                DocumentSnapshot>(
                                            future: _db
                                                .collection("users")
                                                .doc(otherid)
                                                .get(),
                                            builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    documentSnapshot) {
                                              if (documentSnapshot.hasData) {
                                                return Image.network(
                                                    documentSnapshot.data!
                                                        .get("picture_url"));
                                              } else {
                                                return Container(width: 1);
                                              }
                                            }),
                                        title: FutureBuilder<DocumentSnapshot>(
                                            future: _db
                                                .collection("users")
                                                .doc(otherid)
                                                .get(),
                                            builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    documentSnapshot) {
                                              if (documentSnapshot.hasData) {
                                                firstName = documentSnapshot
                                                    .data!
                                                    .get("first_name");
                                                return Text(documentSnapshot
                                                    .data!
                                                    .get("first_name"));
                                              } else {
                                                return Container(width: 1);
                                              }
                                            }),
                                        subtitle: FutureBuilder<
                                                DocumentSnapshot>(
                                            future: _db
                                                .collection("chats")
                                                .doc(e.get("most_recent"))
                                                .get(),
                                            builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    documentSnapshot) {
                                              if (documentSnapshot.hasData) {
                                                return Text(
                                                    "${documentSnapshot.data!.get("owner_id") == myuid ? "You" : firstName} said: ${documentSnapshot.data!.get("message")}");
                                              } else {
                                                return Container(width: 1);
                                              }
                                            }),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (con) => ChatPage(
                                                      uid: otherid,
                                                      name: firstName)));
                                        }));
                              } else {
                                return Container();
                              }
                            }).toList());
                      }
                    }),
        appBar: AppBar(
          title: Text(_title),
          automaticallyImplyLeading: false,
          actions: [
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
