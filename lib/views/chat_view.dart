import 'package:chat_app/auth_class.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ChatPage extends StatefulWidget {
  final String uid;
  final String name;
  const ChatPage(
      {Key? key, required String this.uid, required String this.name})
      : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TextEditingController _messageController;
  late ScrollController _listScrollController;
  String? myuid = FireAuthClass.uid;
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection("chats")
                        .where("conversation_id",
                            isEqualTo: myuid!.compareTo(widget.uid) < 0
                                ? "${myuid}_${widget.uid}"
                                : "${widget.uid}_${myuid}")
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
                            reverse: true,
                            shrinkWrap: true,
                            controller: _listScrollController,
                            children: snapshot.data!.docs.map((e) {
                              if (e.get("owner_id") == myuid) {
                                return Column(
                                  children: [
                                    Bubble(
                                        color: Colors.blue,
                                        alignment: Alignment.topRight,
                                        nip: BubbleNip.rightTop,
                                        child: Text(e.get("message"),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white))),
                                    const SizedBox(height: 10.0)
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Bubble(
                                        color: Colors.blue,
                                        alignment: Alignment.topLeft,
                                        nip: BubbleNip.leftTop,
                                        child: Text(e.get("message"),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white))),
                                    const SizedBox(height: 10.0)
                                  ],
                                );
                              }
                            }).toList());
                      }
                    })),
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      autocorrect: false,
                      controller: _messageController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          hintText: 'Enter Message...'),
                    )),
                    IconButton(
                      onPressed: () {
                        sendMessage(_messageController.text);
                      },
                      icon: Icon(Icons.send),
                    )
                  ],
                ))
          ],
        ),
        appBar: AppBar(
          title: Text(widget.name),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildRatingDialog(
                      context,
                      myuid!.compareTo(widget.uid) < 0
                          ? "${myuid}_${widget.uid}"
                          : "${widget.uid}_${myuid}",
                      widget.uid),
                );
              },
              tooltip: 'Rate Conversation',
              icon: const Icon(Icons.star),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: 'Go Back',
              icon: const Icon(Icons.arrow_back),
            )
          ],
        ));
  }

  Widget _buildRatingDialog(
      BuildContext context, String conversationid, String userid) {
    return AlertDialog(
        title: const Text("Rate this Conversation"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RatingBar.builder(
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (rating) {
                    _db
                        .collection("users")
                        .doc(userid)
                        .collection("ratings")
                        .doc(conversationid)
                        .set({"rating": rating})
                        .then((value) => null)
                        .catchError((error) => print("$error"));
                  }),
              const SizedBox(height: 10.0),
              Center(
                  child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              ))
            ]));
  }

  void sendMessage(String message) {
    if (message.trim() != '') {
      _messageController.clear();
      _listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.easeOut);
      String conversationid = myuid!.compareTo(widget.uid) < 0
          ? "${myuid}_${widget.uid}"
          : "${widget.uid}_${myuid}";
      String chatid;
      var ref = _db.collection("chats").doc();
      chatid = ref.id;
      ref
          .set({
            "timestamp": DateTime.now(),
            "message": message,
            "owner_id": myuid,
            "conversation_id": conversationid
          })
          .then((value) => null)
          .catchError((error) => print("$error"));

      _db
          .collection("conversations")
          .doc(conversationid)
          .set({"most_recent": chatid})
          .then((value) => null)
          .catchError((error) => print("$error"));
    }
  }
}
