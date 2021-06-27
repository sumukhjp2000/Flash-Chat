
// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

final _store = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final loggedInUser = _auth.currentUser;
class ChatScreen extends StatefulWidget {
  static String id = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageController = TextEditingController();
  String messageText;
  void getCurrentUser() async {
    try{
      print(loggedInUser.email);
    }
    catch(e){
      print(e);
    }
  }

  // void getMessages() async {
  //   await for ( var snapshot in _store.collection('messages').snapshots()){
  //     for (var messages in snapshot.docs){
  //       print(messages.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                 _auth.signOut();
                 Navigator.pop(context);
              }),
        ],
        title: Center(child: Text('⚡️Chat')),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                 TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageController.clear();
                      if (messageText!=null) {
                        _store.collection('messages').add({
                          'text': messageText,
                          'sender': _auth.currentUser.email,
                          'timestamp': DateTime.now()
                        });
                      }
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
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>( //Important line
        stream: _store.collection('messages').orderBy("timestamp").snapshots(),
        builder: (context, snapshot){
          List<MessageBubble> messageWidgets = [];
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final messages = snapshot.data.docs.reversed;
          for(var message in messages){
            final messageData = message.data();
            final messageText = messageData['text'];
            final messageSender = messageData['sender'];
            final currentUser  = loggedInUser.email;
            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
            );
            messageWidgets.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.all(8),
              children: messageWidgets,
            ),
          );
        }
    );
  }
}





class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe});
  final String text;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(sender,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13.0
          ),
          ),
          Material(
            borderRadius: isMe? BorderRadius.only(
                topLeft: Radius.circular(30.0) ,
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ): BorderRadius.only(
                topRight: Radius.circular(30.0) ,
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)
            ),
            color: isMe? Colors.lightBlueAccent : Colors.white,
            elevation: 5.0,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                   '$text',
                style: TextStyle(
                  color: isMe? Colors.white: Colors.black,
                  fontSize: 17.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
