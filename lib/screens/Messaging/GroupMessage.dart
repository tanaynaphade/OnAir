// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable, use_key_in_widget_constructors, non_constant_identifier_names, unnecessary_new, unnecessary_string_interpolations, void_checks, unused_local_variable, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:on_air/screens/Homepage/Homepage.dart';
import 'package:on_air/screens/Messaging/GroupMessageHelper.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../constants/Constantcolors.dart';
import '../../services/FirebaseOperations.dart';

class GroupMessage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  GroupMessage({@required this.documentSnapshot});

  @override
  State<GroupMessage> createState() => _GroupMessageState();
}

class _GroupMessageState extends State<GroupMessage> {
  final ConstantColors constantColors = ConstantColors();
  final TextEditingController num = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<GroupMessageHelper>(context, listen: false)
        .checkIfJoined(context, widget.documentSnapshot.id,
            widget.documentSnapshot['useruid'])
        .whenComplete(() async {
      if (Provider.of<GroupMessageHelper>(context, listen: false)
              .getHasMemberJoined ==
          false) {
        Timer(
            Duration(milliseconds: 10),
            () => Provider.of<GroupMessageHelper>(context, listen: false)
                .askToJoin(context, widget.documentSnapshot.id));
      }
    });
    super.initState();
  }

  // const MessagesScreen({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: constantColors.whiteColor,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(PageTransition(
                child: HomePage(), type: PageTransitionType.fade));
          },
        ),
        actions: [
          Provider.of<Authentication>(context, listen: false).userUid ==
                  widget.documentSnapshot['useruid']
              ? IconButton(
                  icon: Icon(EvaIcons.moreVerticalOutline), onPressed: () {})
              : Container(
                  width: 0,
                  height: 0,
                ),
          IconButton(
              icon: Icon(
                EvaIcons.logOutOutline,
                color: constantColors.redColor,
              ),
              onPressed: () {
                Provider.of<GroupMessageHelper>(context, listen: false)
                    .leaveRoom(context, widget.documentSnapshot.id);
              })
        ],
        centerTitle: true,
        backgroundColor: constantColors.darkColor.withOpacity(0.6),
        title: Container(
          width: MediaQuery.of(context).size.width * 0.51,
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.documentSnapshot['roomimage']),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.documentSnapshot['roomname'],
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    // ignore: missing_return
                    StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return new Text(
                            '${snapshot.data.docs.length.toString()} members',
                            style: TextStyle(
                                color: constantColors.blueGreyColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          );
                        }
                        ;
                      },
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.documentSnapshot.id)
                          .collection("members")
                          .snapshots(),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              AnimatedContainer(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width,
                duration: Duration(seconds: 3),
                curve: Curves.bounceIn,
                child: Provider.of<GroupMessageHelper>(context, listen: false)
                    .retrieveMessages(context, widget.documentSnapshot,
                        widget.documentSnapshot['useruid']),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 10, bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: constantColors.blueColor,
                      ),
                      color: constantColors.darkColor.withOpacity(0.7),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<GroupMessageHelper>(context,
                                  listen: false)
                              .showStichers(
                                  context, widget.documentSnapshot.id);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              constantColors.darkColor.withOpacity(0.7),
                          backgroundImage:
                              AssetImage('assets/icons/stickrs_icon.png'),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Drop A Message',
                              hintStyle: TextStyle(
                                  color: constantColors.greenColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                      GestureDetector(
                        child: FloatingActionButton(
                          backgroundColor: constantColors.blueColor,
                          child: Icon(
                            Icons.send_sharp,
                            color: constantColors.whiteColor,
                          ),
                          onPressed: () {
                            if (messageController.text.isNotEmpty) {
                              Provider.of<GroupMessageHelper>(context,
                                      listen: false)
                                  .sendMessage(context, messageController,
                                      widget.documentSnapshot);
                              messageController.clear();
                            }
                          },
                        ),
                        onLongPress: () async {
                          if (messageController.text.isNotEmpty) {
                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: constantColors.darkColor,
                                    title: TextField(
                                      controller: num,
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        hintText: 'Number of seconds to delay',
                                        hintStyle: TextStyle(
                                            color: constantColors.greenColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    actions: [
                                      MaterialButton(
                                          color: constantColors.redColor,
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color:
                                                    constantColors.whiteColor,
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    constantColors.whiteColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                      MaterialButton(
                                          color: constantColors.blueColor,
                                          child: Text(
                                            "Confirm",
                                            style: TextStyle(
                                                color:
                                                    constantColors.whiteColor,
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    constantColors.whiteColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () async {
                                            int a = int.parse(num.text);
                                            await Future.delayed(
                                                Duration(seconds: a), () {
                                              FirebaseFirestore.instance
                                                  .collection('chatrooms')
                                                  .doc(widget
                                                      .documentSnapshot.id)
                                                  .collection('messages')
                                                  .add({
                                                'message':
                                                    messageController.text,
                                                'time': Timestamp.now(),
                                                'useruid':
                                                    Provider.of<Authentication>(
                                                            context,
                                                            listen: false)
                                                        .userUid,
                                                'username': Provider.of<
                                                            FirebaseOperations>(
                                                        context,
                                                        listen: false)
                                                    .getInitUserName,
                                                'userimage': Provider.of<
                                                            FirebaseOperations>(
                                                        context,
                                                        listen: false)
                                                    .getInitUserImage,
                                                'sticker': ""
                                              });
                                            });
                                            messageController.clear();
                                            num.clear();
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
