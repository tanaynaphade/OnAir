import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:on_air/screens/LandingPage/landingUtils.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FirebaseOperations with ChangeNotifier {
  UploadTask imageUploadTask;
  bool init = false;
  String initUserEmail, initUserName, initUserImage;
  String get getInitUserName => initUserName;
  String get getInitUserEmail => initUserEmail;
  String get getInitUserImage => initUserImage;

  Future uploadUserAvatar(BuildContext context) async {
    Reference imageReference = FirebaseStorage.instance.ref().child(
        'userProfileAvatar/${Provider.of<LandingUtils>(context, listen: false).getUserAvatar.path}/${TimeOfDay.now()}');
    imageUploadTask = imageReference.putFile(
        Provider.of<LandingUtils>(context, listen: false).getUserAvatar);
    await imageUploadTask.whenComplete(() {
      print("image uploaded!");
    });
    imageReference.getDownloadURL().then((value) {
      Provider.of<LandingUtils>(context, listen: false).userAvatarUrl =
          value.toString();
      print(
          'the user profile avatar url => ${Provider.of<LandingUtils>(context, listen: false).getUserAvatar}');
      notifyListeners();
    });
  }

  Future createUserCollection(BuildContext context, dynamic data) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .set(data);
  }

  Future initUserData(BuildContext context) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .get()
        .then((doc) {
      print('Fetching user data');
      initUserName = doc.data()["username"];
      initUserEmail = doc.data()['useremail'];
      initUserImage = doc.data()['userimage'];
      print(initUserName);
      print(initUserEmail);
      print(initUserImage);
      init = true;
      notifyListeners();
    });
  }

  Future uploadPostData(String postId, dynamic data) async {
    return FirebaseFirestore.instance.collection('post').doc(postId).set(data);
  }

  Future deleteUserData(String userUid, dynamic collection) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(userUid)
        .delete();
  }

  Future addAward(String postId, dynamic data) async {
    return FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .collection('award')
        .add(data);
  }

  Future updateCaption(String postId, dynamic data) async {
    return FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .update(data);
  }

  Future followUser(
    String followingUid,
    String followingDocId,
    dynamic followingData,
    String followerUid,
    String followerDocId,
    dynamic followerData,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followingUid)
        .collection('followers')
        .doc(followingDocId)
        .set(followingData)
        .whenComplete(() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(followerUid)
          .collection('following')
          .doc(followerDocId)
          .set(followerData);
    });
  }

  Future uploadChatRoomData(
    BuildContext context,
    String chatRoomId,
    dynamic chatRoomdata,
  ) async {
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .set(chatRoomdata);
  }
}
