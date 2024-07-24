// ignore_for_file: prefer_const_constructors, unnecessary_new, missing_return, prefer_is_empty

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_air/screens/Chatroom/ChatroomHelper.dart';
import 'package:on_air/screens/Messaging/GroupMessage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants/Constantcolors.dart';

class Chatroom extends StatelessWidget {
  String latestMessageTime;
  String get getLastMessageTime => latestMessageTime;
  final ConstantColors constantColors = ConstantColors();
  // const ChatScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              EvaIcons.plus,
              color: constantColors.lightB1ueColor,
            ),
            onPressed: () {
              Provider.of<ChatroomHelper>(context, listen: false)
                  .showImageSourceSheet(context);
            }),
        actions: [
          IconButton(
              icon: Icon(
                EvaIcons.moreVertical,
                color: constantColors.greenColor,
              ),
              onPressed: () {})
        ],
        centerTitle: true,
        backgroundColor: constantColors.darkColor.withOpacity(0.6),
        title: RichText(
            text: TextSpan(
                text: 'Chat ',
                style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                children: <TextSpan>[
              TextSpan(
                text: 'Room',
                style: TextStyle(
                    color: constantColors.blueColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
            ])),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: constantColors.blueGreyColor,
          child: Icon(
            FontAwesomeIcons.plus,
            color: constantColors.greenColor,
          ),
          onPressed: () {
            Provider.of<ChatroomHelper>(context, listen: false)
                .showImageSourceSheet(context);
          }),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chatrooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return new ListView(
              children:
                  snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                return ListTile(
                    onTap: () {
                      Timer(Duration(milliseconds: 200), () {
                        Navigator.of(context).pushReplacement(PageTransition(
                            child: GroupMessage(
                                documentSnapshot: documentSnapshot),
                            type: PageTransitionType.leftToRight));
                      });
                    },
                    onLongPress: () {
                      Provider.of<ChatroomHelper>(context, listen: false)
                          .showChatRoomMembers(context, documentSnapshot);
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: constantColors.transperant,
                      backgroundImage:
                          NetworkImage(documentSnapshot['roomimage']),
                    ),
                    title: Text(
                      documentSnapshot['roomname'],
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(documentSnapshot.id)
                          .collection('messages')
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          if (snapshot.data.docs.first['username'] != null &&
                              snapshot.data.docs.first['sticker'] == "") {
                            return Text(
                              "${snapshot.data.docs.first['username']}: ${snapshot.data.docs.first['message']}",
                              style: TextStyle(
                                  color: constantColors.greenColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            );
                          } else {
                            return Text(
                              "${snapshot.data.docs.first['username']}: sent a Sticker",
                              style: TextStyle(
                                  color: constantColors.greenColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    trailing: Container(
                        width: 0,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chatrooms')
                              .doc(documentSnapshot.id)
                              .collection('messages')
                              .orderBy('time', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              showLastMessageTime(
                                  snapshot.data.docs.first['time']);
                              return Text(
                                getLastMessageTime,
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )));
              }).toList(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  showLastMessageTime(dynamic TimeData) {
    Timestamp t = TimeData;
    DateTime dateTime = t.toDate();
    latestMessageTime = timeago.format(dateTime);
  }
}
