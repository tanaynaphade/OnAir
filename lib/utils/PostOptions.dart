// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unnecessary_new, missing_return

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_air/screens/AltProfile/alt_profile.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../constants/Constantcolors.dart';
import '../services/FirebaseOperations.dart';

class PostFuntions with ChangeNotifier {
  TextEditingController commentController = TextEditingController();
  ConstantColors constantColors = ConstantColors();
  String imageTimeUploaded;
  String get getImageTimeUploaded => imageTimeUploaded;
  TextEditingController newCaptionController = TextEditingController();

  showImageTime(dynamic timedata) {
    Timestamp time = timedata;
    DateTime dateTime = time.toDate();
    imageTimeUploaded = timeago.format(dateTime);
    print(imageTimeUploaded);
    notifyListeners();
  }

  Future addLike(BuildContext context, String postId, String subDocId) async {
    await FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .collection('likes')
        .doc(subDocId)
        .set({
      'likes': FieldValue.increment(1),
      'username': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserName,
      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserImage,
      'useremail': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserEmail,
      'time': Timestamp.now()
    });
  }

  Future addComment(BuildContext context, String postId, String comment) async {
    await FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .collection('comments')
        .doc(comment)
        .set({
      'comment': comment,
      'username': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserName,
      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserImage,
      'useremail': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserEmail,
      'time': Timestamp.now()
    });
  }

  showCommentSheet(
      BuildContext context, DocumentSnapshot snapshot, String docId) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: constantColors.blueGreyColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  )),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: constantColors.whiteColor),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        'Comments',
                        style: TextStyle(
                            color: constantColors.blueColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.53,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('post')
                          .doc(docId)
                          .collection('comments')
                          .orderBy('time')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return new ListView(
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot documentSnapshot) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.17,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                PageTransition(
                                                    child: AltProfileScreen(
                                                        userUid:
                                                            documentSnapshot[
                                                                'useruid']),
                                                    type: PageTransitionType
                                                        .bottomToTop));
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                documentSnapshot['userimage']),
                                            backgroundColor:
                                                constantColors.darkColor,
                                            radius: 15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Container(
                                          child: Text(
                                            documentSnapshot['username'],
                                            style: TextStyle(
                                                color:
                                                    constantColors.whiteColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Row(
                                          children: [
                                            IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.arrowUp,
                                                  size: 12,
                                                  color:
                                                      constantColors.whiteColor,
                                                ),
                                                onPressed: () {}),
                                            Text(
                                              '0',
                                              style: TextStyle(
                                                  color:
                                                      constantColors.whiteColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.trash,
                                                  size: 12,
                                                  color:
                                                      constantColors.redColor,
                                                ),
                                                onPressed: () {}),
                                            IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.reply,
                                                  size: 12,
                                                  color: constantColors
                                                      .yellowColor,
                                                ),
                                                onPressed: () {}),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: constantColors.blueColor,
                                              size: 12,
                                            ),
                                            onPressed: () {}),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          child: Text(
                                            documentSnapshot['comment'],
                                            style: TextStyle(
                                                color:
                                                    constantColors.whiteColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 50),
                                          child: IconButton(
                                              icon: Icon(
                                                FontAwesomeIcons.trash,
                                                color: constantColors.redColor,
                                              ),
                                              onPressed: () {}),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: constantColors.darkColor
                                        .withOpacity(0.2),
                                  )
                                ],
                              ),
                            );
                          }).toList());
                        }
                      },
                    ),
                  ),
                  Container(
                      width: 400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 300,
                            height: 20,
                            child: TextField(
                              controller: commentController,
                              style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Add Comment...',
                                hintStyle: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          FloatingActionButton(
                              backgroundColor: constantColors.greenColor,
                              child: Icon(
                                FontAwesomeIcons.comment,
                                color: constantColors.whiteColor,
                              ),
                              onPressed: () {
                                print('Adding Comment..');
                                addComment(context, snapshot['caption'],
                                        commentController.text)
                                    .whenComplete(() {
                                  commentController.clear();
                                  notifyListeners();
                                });
                              })
                        ],
                      )),
                ],
              ),
            ),
          );
        });
  }

  showLikeSheet(
    BuildContext context,
    String postId,
  ) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                      border: Border.all(color: constantColors.whiteColor),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                    child: Text(
                      'Likes',
                      style: TextStyle(
                          color: constantColors.blueColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('post')
                        .doc(postId)
                        .collection('likes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return new ListView(
                            children: snapshot.data.docs
                                .map((DocumentSnapshot documentSnapshot) {
                          return ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          child: AltProfileScreen(
                                              userUid:
                                                  documentSnapshot['useruid']),
                                          type:
                                              PageTransitionType.bottomToTop));
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      documentSnapshot['userimage']),
                                ),
                              ),
                              title: Text(
                                documentSnapshot['username'],
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                documentSnapshot['useremail'],
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Provider.of<Authentication>(context,
                                              listen: false)
                                          .userUid ==
                                      documentSnapshot['useruid']
                                  ? Container(
                                      width: 0,
                                      height: 0,
                                    )
                                  : MaterialButton(
                                      color: constantColors.blueColor,
                                      child: Text(
                                        'Follow',
                                        style: TextStyle(
                                            color: constantColors.whiteColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {}));
                        }).toList());
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  showRewards(BuildContext context, String postId) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                    border: Border.all(color: constantColors.whiteColor),
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: Text(
                    'Rewards',
                    style: TextStyle(
                        color: constantColors.blueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('awards')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs
                            .map((DocumentSnapshot documentSnapshot) {
                          List<dynamic> images = documentSnapshot['image'];
                          return Row(
                            children: images.map((image) {
                              return GestureDetector(
                                onTap: () async {
                                  print(image);
                                  await Provider.of<FirebaseOperations>(context,
                                          listen: false)
                                      .addAward(postId, {
                                    'username': Provider.of<FirebaseOperations>(
                                            context,
                                            listen: false)
                                        .getInitUserName,
                                    'userimage':
                                        Provider.of<FirebaseOperations>(context,
                                                listen: false)
                                            .getInitUserImage,
                                    'useruid': Provider.of<Authentication>(
                                            context,
                                            listen: false)
                                        .getUserUid,
                                    'time': Timestamp.now(),
                                    'award': documentSnapshot['image']
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(image),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              )
            ]),
          );
        });
  }

  showImageOptionsSheet(BuildContext context, String postId) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
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
                    color: constantColors.whiteColor,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          color: constantColors.blueColor,
                          child: Text(
                            'Edit Caption',
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    child: Center(
                                        child: Row(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 50,
                                          child: TextField(
                                            controller: newCaptionController,
                                            decoration: InputDecoration(
                                              hintText: 'Add New Caption...',
                                              hintStyle: TextStyle(
                                                  color:
                                                      constantColors.whiteColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: TextStyle(
                                                color:
                                                    constantColors.whiteColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        FloatingActionButton(
                                            backgroundColor:
                                                constantColors.blueColor,
                                            child: Icon(
                                              FontAwesomeIcons.fileUpload,
                                              color: constantColors.whiteColor,
                                            ),
                                            onPressed: () {
                                              Provider.of<FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .updateCaption(postId, {
                                                'caption':
                                                    newCaptionController.text
                                              });
                                            })
                                      ],
                                    )),
                                  );
                                });
                          }),
                      MaterialButton(
                          color: constantColors.redColor,
                          child: Text(
                            'Delete Post',
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            deletePostDialog(context, postId);
                          }),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  deletePostDialog(BuildContext context, String postId) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: constantColors.darkColor,
            title: Text(
              'Delete Post?',
              style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              MaterialButton(
                  color: constantColors.blueColor,
                  child: Text(
                    'No',
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              MaterialButton(
                  color: constantColors.redColor,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Provider.of<FirebaseOperations>(context, listen: false)
                        .deleteUserData(postId, 'post')
                        .whenComplete(() {
                      Navigator.pop(context);
                    });
                  })
            ],
          );
        });
  }
}
