// ignore_for_file: prefer_const_constructors, unnecessary_new, sized_box_for_whitespace, sort_child_properties_last, missing_return, void_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:on_air/services/FirebaseOperations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants/Constantcolors.dart';
import '../Homepage/Homepage.dart';

class GroupMessageHelper with ChangeNotifier {
  bool hasMemberJoined = false;
  final TextEditingController num1 = TextEditingController();
  String lastMessageTime;
  String get getLastMessageTime => lastMessageTime;
  get getHasMemberJoined => hasMemberJoined;
  ConstantColors constantColors = ConstantColors();

  sendMessage(BuildContext context, TextEditingController messageController,
      DocumentSnapshot documentSnapshot) {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(documentSnapshot.id)
        .collection('messages')
        .add({
      'message': messageController.text,
      'time': Timestamp.now(),
      'useruid': Provider.of<Authentication>(context, listen: false).userUid,
      'username': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserName,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserImage,
      'sticker': ""
    });
  }

  retrieveMessages(
      BuildContext context, DocumentSnapshot documentSnapshot, String adminId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(documentSnapshot.id)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return new ListView(
              reverse: true,
              children:
                  snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                showLastMessageTime(documentSnapshot['time']);
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: documentSnapshot['sticker'] == ""
                        ? MediaQuery.of(context).size.height * 0.108
                        : MediaQuery.of(context).size.height * 0.207,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 35, bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.2,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Provider.of<Authentication>(context,
                                                    listen: false)
                                                .userUid ==
                                            documentSnapshot['useruid']
                                        ? constantColors.darkColor
                                            .withOpacity(0.8)
                                        : constantColors.darkColor),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 140,
                                        child: Row(
                                          children: [
                                            Text(
                                              documentSnapshot['username'],
                                              style: TextStyle(
                                                  color:
                                                      constantColors.greenColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Provider.of<Authentication>(context,
                                                            listen: false)
                                                        .userUid ==
                                                    adminId
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Icon(
                                                      FontAwesomeIcons
                                                          .chessKing,
                                                      color: constantColors
                                                          .yellowColor,
                                                      size: 12,
                                                    ),
                                                  )
                                                : Container(
                                                    width: 0,
                                                    height: 0,
                                                  )
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: constantColors.greenColor
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50))),
                                          child: GestureDetector(
                                            child: documentSnapshot[
                                                        'sticker'] ==
                                                    ""
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      documentSnapshot[
                                                          'message'],
                                                      style: TextStyle(
                                                          color: constantColors
                                                              .whiteColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: Image.network(
                                                          documentSnapshot[
                                                              'sticker']),
                                                    )),
                                            onLongPress: () {
                                              return showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          constantColors
                                                              .darkColor,
                                                      title: TextField(
                                                        controller: num1,
                                                        style: TextStyle(
                                                            color:
                                                                constantColors
                                                                    .whiteColor,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Number of minutes to distruct',
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  constantColors
                                                                      .greenColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      actions: [
                                                        MaterialButton(
                                                            color:
                                                                constantColors
                                                                    .redColor,
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(
                                                                  color: constantColors
                                                                      .whiteColor,
                                                                  fontSize: 14,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      constantColors
                                                                          .whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        MaterialButton(
                                                            color:
                                                                constantColors
                                                                    .blueColor,
                                                            child: Text(
                                                              "Confirm",
                                                              style: TextStyle(
                                                                  color: constantColors
                                                                      .whiteColor,
                                                                  fontSize: 14,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      constantColors
                                                                          .whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              final time =
                                                                  int.parse(num1
                                                                      .text);
                                                              await Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          time),
                                                                  () {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'chatrooms')
                                                                    .doc(
                                                                        documentSnapshot
                                                                            .id)
                                                                    .collection(
                                                                        'messages')
                                                                    .doc(
                                                                        documentSnapshot
                                                                            .id)
                                                                    .delete();
                                                              });
                                                            }),
                                                      ],
                                                    );
                                                  });
                                            },
                                          )),
                                      Container(
                                        width: 100,
                                        child: Text(
                                          getLastMessageTime,
                                          style: TextStyle(
                                              color: constantColors.whiteColor,
                                              fontSize: 10),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                            top: 15,
                            child: Provider.of<Authentication>(context,
                                            listen: false)
                                        .userUid ==
                                    documentSnapshot['useruid']
                                ? Container(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 15,
                                          ),
                                          onPressed: () {},
                                          color: constantColors.blueColor,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.trashAlt,
                                            size: 18,
                                          ),
                                          onPressed: () {},
                                          color: constantColors.redColor,
                                        )
                                      ],
                                    ),
                                  )
                                : Container(
                                    width: 0,
                                    height: 0,
                                  )),
                        Positioned(
                            left: 10,
                            child: Provider.of<Authentication>(context,
                                            listen: false)
                                        .userUid ==
                                    documentSnapshot['useruid']
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : CircleAvatar(
                                    radius: 15,
                                    backgroundColor: constantColors.darkColor,
                                    backgroundImage: NetworkImage(
                                        documentSnapshot['userimage']),
                                  ))
                      ],
                    ),
                  ),
                );
              }).toList());
        }
      },
    );
  }

  Future checkIfJoined(BuildContext context, String chatRoomName,
      String chatroomAdminUid) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomName)
        .collection('members')
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .get()
        .then((value) {
      hasMemberJoined = false;
      print('Inital state => $hasMemberJoined');
      if (value.data()['joined'] != null) {
        hasMemberJoined = value.data()['joined'];
        print('Final state => $hasMemberJoined');
        notifyListeners();
      }
      if (Provider.of<Authentication>(context, listen: false).getUserUid ==
          chatroomAdminUid) {
        hasMemberJoined = true;
        notifyListeners();
      }
    });
  }

  askToJoin(BuildContext context, String roomname) {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            backgroundColor: constantColors.darkColor,
            title: Text(
              "Join $roomname?",
              style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              MaterialButton(
                  child: Text("no",
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: constantColors.whiteColor,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: HomePage(),
                            type: PageTransitionType.bottomToTop));
                  }),
              MaterialButton(
                  color: constantColors.blueColor,
                  child: Text("yes",
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(roomname)
                        .collection("members")
                        .doc(Provider.of<Authentication>(context, listen: false)
                            .getUserUid)
                        .set({
                      'joined': true,
                      'username': Provider.of<FirebaseOperations>(context,
                              listen: false)
                          .getInitUserName,
                      'userimage': Provider.of<FirebaseOperations>(context,
                              listen: false)
                          .getInitUserImage,
                      'useruid':
                          Provider.of<Authentication>(context, listen: false)
                              .getUserUid,
                      'time': Timestamp.now()
                    }).whenComplete(() {
                      Navigator.pop(context);
                    });
                  }),
            ],
          );
        });
  }

  showStichers(BuildContext context, String chatroomId) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 105),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: constantColors.blueColor)),
                      height: 30,
                      width: 30,
                      child: Image.asset('assets\\icons\\stickrs_icon.png'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Stickers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return new GridView(
                          children: snapshot.data.docs
                              .map((DocumentSnapshot documentSnapshot) {
                            return GestureDetector(
                              onTap: () {
                                sendStickers(context, documentSnapshot['image'],
                                    chatroomId);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                child: Image.network(documentSnapshot['image']),
                              ),
                            );
                          }).toList(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )
            ]),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                color: constantColors.darkColor),
          );
        });
  }

  sendStickers(
      BuildContext context, String stickerImageUrl, String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'sticker': stickerImageUrl,
      'username':
          Provider.of<FirebaseOperations>(context, listen: false).initUserName,
      'userimage':
          Provider.of<FirebaseOperations>(context, listen: false).initUserImage,
      'time': Timestamp.now(),
      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
    });
  }

  showLastMessageTime(dynamic timeData) {
    Timestamp time = timeData;
    DateTime dateTime = time.toDate();
    lastMessageTime = timeago.format(dateTime);
    print(lastMessageTime);
    notifyListeners();
  }

  leaveRoom(BuildContext context, String chatRoomName) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: constantColors.darkColor,
            title: Text(
              "Leave the Chat?",
              style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              MaterialButton(
                color: constantColors.redColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: TextStyle(
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: constantColors.whiteColor,
                      fontSize: 14),
                ),
              ),
              MaterialButton(
                color: constantColors.blueColor,
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(chatRoomName)
                      .collection('members')
                      .doc(Provider.of<Authentication>(context, listen: false)
                          .getUserUid)
                      .delete()
                      .whenComplete(() {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: HomePage(),
                            type: PageTransitionType.bottomToTop));
                  });
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              )
            ],
          );
        });
  }
}
