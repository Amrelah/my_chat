import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

final _firestore = FirebaseFirestore.instance;

late User loggedinUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String messageText;

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessages() async {
    await for (var snapshut in _firestore
        .collection('messages')
        .orderBy('Date', descending: false)
        .snapshots()) {
      for (var message in snapshut.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    getMessages();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                getMessages();
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Expanded(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessageStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        messageTextController.clear();
                        Navigator.pop(context);
                        _firestore.collection("messages").add({
                          'sender': loggedinUser.email,
                          'text': messageText,
                          'Date': DateTime.now(),
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageStream extends StatefulWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  @override
  Widget build(BuildContext context) {
    List<MessageBubble> messageWidget = [];
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('Date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // if (!snapshot.hasData) {
          //   return Center(
          //     child: Icon(
          //       Icons.noise_aware_rounded,
          //       size: 100,
          //       color: Colors.black,
          //     ),
          //   );
          // }

          // final mesage = snapshot.data?.docs;
          // for (var message in mesage!) {
          //   final messageText = message.get('text');
          //   final messageSender = message.get('sender');
          //
          //   final mesageWidget =
          //       Text('$messageText  from  $messageSender');
          //   messageWidget.add(mesageWidget);
          // }
          //
          // return Column(
          //   children: messageWidget,
          // );
          if (snapshot.data?.docChanges == null) {
            return Expanded(
              child: Icon(
                Icons.noise_aware_rounded,
                size: 100,
                color: Colors.black,
              ),
            );
          } else {
            final mesage = snapshot.data?.docs;
            var mesageBubble;
            for (var message in mesage!) {
              final messageText = message['text'];
              final messageSender = message['sender'];
              mesageBubble = MessageBubble(
                  messageText: messageText, messageSender: messageSender);
              messageWidget.add(mesageBubble);
              print(messageText);
              print(messageWidget.length);
            }

            return Flexible(
                child: ListView(
              padding: EdgeInsets.only(bottom: 0.0),
              reverse: true,
              children: messageWidget,
            ));
          }
        });
  }
}

class MessageBubble extends StatelessWidget {
  late final String messageText;
  late final String messageSender;
  MessageBubble({required this.messageText, required this.messageSender});
  Color contColor = Colors.lightBlueAccent;
  Alignment align = Alignment.centerRight;
  bool vis = true;
  double tr = 0.0;
  double bl = 30.0;
  @override
  Widget build(BuildContext context) {
    if (messageSender == loggedinUser.email) {
      contColor = Colors.black45;
      align = Alignment.centerLeft;
      vis = false;
      tr = 30.0;
      bl = 0.0;
    }
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Align(
        alignment: align,
        child: Material(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(tr),
                bottomLeft: Radius.circular(bl),
                topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: contColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                children: [
                  Visibility(
                    visible: vis,
                    child: Text(messageSender,
                        style:
                            TextStyle(fontSize: 12.0, color: Colors.black45)),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    messageText,
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
