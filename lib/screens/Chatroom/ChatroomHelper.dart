// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, sort_child_properties_last, missing_return, unnecessary_new, void_checks

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:on_air/screens/AltProfile/alt_profile.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:on_air/services/FirebaseOperations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants/Constantcolors.dart';
import '../Homepage/Homepage.dart';

class ChatroomHelper with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  TextEditingController chatRoomNameController = TextEditingController();
  File chatRoomImage;
  File get getchatRoomImage => chatRoomImage;
  String chatRoomImageUrl;
  String get getchatRoomImageUrl => chatRoomImageUrl;
  final picker = ImagePicker();
  UploadTask chatRoomImageUploadTask;
  String chatRoomId;
  String get getchatRoomId => chatRoomId;

  Future getChatRoomImage(BuildContext context, ImageSource imageSource) async {
    final chatImagePicked = await picker.pickImage(source: imageSource);

    chatImagePicked == null
        ? print('Select ChatRoom Image')
        : chatRoomImage = File(chatImagePicked.path);
    print(chatImagePicked.path);

    chatRoomImage != null
        ? Provider.of<ChatroomHelper>(context, listen: false)
            .showImageChatroom(context)
        : print('Error Getting ChatImage');
    notifyListeners();
  }

  Future chatRoomImageToFirebaseStorage() async {
    Reference imageReference = FirebaseStorage.instance
        .ref()
        .child('chatrooms/${chatRoomImage.path}/${TimeOfDay.now()}');

    chatRoomImageUploadTask = imageReference.putFile(chatRoomImage);

    await chatRoomImageUploadTask.whenComplete(() {
      print('Image Has Been Uploaded To Storage');
    });

    imageReference.getDownloadURL().then((imageUrl) {
      chatRoomImageUrl = imageUrl;
      print(chatRoomImageUrl);
    });

    notifyListeners();
  }

  showImageSourceSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: constantColors.blueGreyColor),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        color: constantColors.blueColor,
                        child: Text(
                          'Camera',
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          getChatRoomImage(context, ImageSource.camera);
                        }),
                    MaterialButton(
                        color: constantColors.redColor,
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          getChatRoomImage(context, ImageSource.gallery);
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  showImageChatroom(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.darkColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                  child: Container(
                    height: 200,
                    width: 400,
                    child: Image.file(chatRoomImage),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          color: constantColors.blueColor,
                          child: Text(
                            'Reselect Image',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            showImageSourceSheet(context);
                          }),
                      MaterialButton(
                          color: constantColors.redColor,
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            chatRoomImageToFirebaseStorage().whenComplete(() {
                              showCreateChatroomSheet(context);
                              print('Image Uploaded');
                            });
                          })
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  showCreateChatroomSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: constantColors.blueGreyColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Container(
                      height: 100,
                      width: 100,
                      child: Image.file(
                        chatRoomImage,
                        fit: BoxFit.contain,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: chatRoomNameController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter ChatRoom Name',
                              hintStyle: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        FloatingActionButton(
                            backgroundColor: constantColors.blueGreyColor,
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: constantColors.yellowColor,
                            ),
                            onPressed: () async {
                              Provider.of<FirebaseOperations>(context,
                                      listen: false)
                                  .uploadChatRoomData(
                                      context, chatRoomNameController.text, {
                                'roomimage': getchatRoomImageUrl,
                                'time': Timestamp.now(),
                                'roomname': chatRoomNameController.text,
                                'adminname': Provider.of<FirebaseOperations>(
                                        context,
                                        listen: false)
                                    .getInitUserName,
                                'adminimage': Provider.of<FirebaseOperations>(
                                        context,
                                        listen: false)
                                    .getInitUserImage,
                                'adminemail': Provider.of<FirebaseOperations>(
                                        context,
                                        listen: false)
                                    .getInitUserEmail,
                                'useruid': Provider.of<Authentication>(context,
                                        listen: false)
                                    .userUid
                              }).whenComplete(() async {
                                await FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .doc(chatRoomNameController.text)
                                    .collection('messages')
                                    .add({
                                  'message': 'Chat was created',
                                  'sticker': "",
                                  'username': Provider.of<FirebaseOperations>(
                                          context,
                                          listen: false)
                                      .initUserName,
                                  'userimage': Provider.of<FirebaseOperations>(
                                          context,
                                          listen: false)
                                      .initUserImage,
                                  'time': Timestamp.now(),
                                  'useruid': Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserUid,
                                });
                                Navigator.of(context).pop();
                              });
                            })
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  showChatRoomMembers(BuildContext context, DocumentSnapshot documentSnapshot) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.blueColor,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: constantColors.blueColor,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Members',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(documentSnapshot.id)
                        .collection("members")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return new Center(child: CircularProgressIndicator());
                      } else {
                        return new ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data.docs
                                .map((DocumentSnapshot documentSnapshot) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (Provider.of<Authentication>(context,
                                                listen: false)
                                            .getUserUid !=
                                        documentSnapshot["useruid"]) {
                                      Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              child: AltProfileScreen(
                                                userUid:
                                                    documentSnapshot["useruid"],
                                              ),
                                              type: PageTransitionType
                                                  .bottomToTop));
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 25.0,
                                    backgroundColor: constantColors.darkColor,
                                    backgroundImage: NetworkImage(
                                        documentSnapshot['userimage']),
                                  ),
                                ),
                              );
                            }).toList());
                      }
                      ;
                    },
                  ),
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.yellowColor,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: constantColors.yellowColor,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: constantColors.transperant,
                              backgroundImage:
                                  NetworkImage(documentSnapshot['adminimage']),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                documentSnapshot['adminname'],
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: constantColors.darkColor,
                                  title: Text(
                                    "Delete the Chat?",
                                    style: TextStyle(
                                        color: constantColors.whiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  actions: [
                                    MaterialButton(
                                      color: constantColors.blueColor,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                            color: constantColors.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    MaterialButton(
                                      color: constantColors.redColor,
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('chatrooms')
                                            .doc(documentSnapshot.id)
                                            .delete()
                                            .whenComplete(() {
                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  child: HomePage(),
                                                  type: PageTransitionType
                                                      .bottomToTop));
                                        });
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                            color: constantColors.whiteColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        color: constantColors.redColor,
                        child: Text(
                          'Delete Chat',
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
