// ignore_for_file: prefer_const_constructors, sort_child_properties_last, missing_required_param, missing_return, unnecessary_new, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, non_constant_identifier_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:on_air/constants/Constantcolors.dart';
import 'package:on_air/screens/AltProfile/alt_profile.dart';
import 'package:on_air/utils/PostOptions.dart';
import 'package:on_air/utils/UploadPost.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../services/Authentication.dart';

class FeedHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  Widget appBar(BuildContext context) {
    ConstantColors constantColors = ConstantColors();
    return AppBar(
      backgroundColor: constantColors.blueGreyColor.withOpacity(0.3),
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () {
              Provider.of<UploadPost>(context, listen: false)
                  .selectPostImageType(context);
            },
            icon: Icon(
              Icons.camera_enhance_rounded,
              color: constantColors.greenColor,
            ))
      ],
      title: RichText(
        text: TextSpan(
            text: " My ",
            style: TextStyle(
              color: constantColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
            children: <TextSpan>[
              TextSpan(
                text: "Feed",
                style: TextStyle(
                  color: constantColors.blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              )
            ]),
      ),
    );
  }

  final _stream = FirebaseFirestore.instance.collection('post').snapshots();
  Widget feedBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          child: StreamBuilder(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return loadPosts(context, snapshot);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          decoration: BoxDecoration(
            color: constantColors.darkColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          ),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget loadPosts(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    print('load');
    return ListView(
        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
      Provider.of<PostFuntions>(context, listen: false)
          .showImageTime(documentSnapshot['time']);
      print('in snapshot');
      return Container(
        height: MediaQuery.of(context).size.height * 0.60,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (documentSnapshot['useruid'] !=
                          Provider.of<Authentication>(context, listen: false)
                              .userUid) {
                        Navigator.of(context).pushReplacement(PageTransition(
                            child: AltProfileScreen(
                              userUid: documentSnapshot['useruid'],
                            ),
                            type: PageTransitionType.leftToRight));
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: constantColors.transperant,
                      radius: 20.0,
                      backgroundImage: NetworkImage((documentSnapshot.data()
                          as Map<String, dynamic>)["userimage"]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                child: Text(
                                    (documentSnapshot.data()
                                        as Map<String, dynamic>)["caption"],
                                    style: TextStyle(
                                      color: constantColors.greenColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ))),
                            Container(
                              child: RichText(
                                text: TextSpan(
                                    text: (documentSnapshot.data()
                                        as Map<String, dynamic>)["username"],
                                    style: TextStyle(
                                      color: constantColors.blueColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              ', ${Provider.of<PostFuntions>(context, listen: false).getImageTimeUploaded.toString()}',
                                          style: TextStyle(
                                            color: constantColors.lightColor
                                                .withOpacity(0.8),
                                          ))
                                    ]),
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.46,
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                  child: Image.network(
                    (documentSnapshot.data()
                        as Map<String, dynamic>)["postimage"],
                    scale: 2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              Provider.of<PostFuntions>(context, listen: false)
                                  .showLikeSheet(
                                      context, documentSnapshot['caption']);
                            },
                            onTap: () {
                              print('adding like');
                              Provider.of<PostFuntions>(context, listen: false)
                                  .addLike(
                                      context,
                                      documentSnapshot['caption'],
                                      Provider.of<Authentication>(context,
                                              listen: false)
                                          .getUserUid);
                            },
                            child: Icon(
                              FontAwesomeIcons.heart,
                              color: constantColors.redColor,
                              size: 22.0,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('post')
                                  .doc(documentSnapshot['caption'])
                                  .collection('likes')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      snapshot.data.docs.length.toString(),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })
                        ],
                      ),
                    ),
                    Container(
                      width: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Provider.of<PostFuntions>(context, listen: false)
                                  .showCommentSheet(context, documentSnapshot,
                                      documentSnapshot['caption']);
                            },
                            child: Icon(
                              FontAwesomeIcons.comment,
                              color: constantColors.blueColor,
                              size: 22.0,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('post')
                                  .doc(documentSnapshot['caption'])
                                  .collection('comments')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      snapshot.data.docs.length.toString(),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })
                        ],
                      ),
                    ),
                    Container(
                      width: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Provider.of<PostFuntions>(context, listen: false)
                                  .showRewards(
                                      context, documentSnapshot['caption']);
                            },
                            child: Icon(
                              FontAwesomeIcons.award,
                              color: constantColors.yellowColor,
                              size: 22.0,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('post')
                                  .doc(documentSnapshot['caption'])
                                  .collection('award')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      snapshot.data.docs.length.toString(),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })
                        ],
                      ),
                    ),
                    Spacer(),
                    Provider.of<Authentication>(context, listen: false)
                                .getUserUid ==
                            (documentSnapshot.data()
                                as Map<String, dynamic>)["useruid"]
                        ? IconButton(
                            onPressed: () {
                              Provider.of<PostFuntions>(context, listen: false)
                                  .showImageOptionsSheet(
                                      context, documentSnapshot['caption']);
                            },
                            icon: Icon(
                              EvaIcons.moreVertical,
                              color: constantColors.whiteColor,
                            ))
                        : Container(
                            width: 0.0,
                            height: 0.0,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList());
  }
}
