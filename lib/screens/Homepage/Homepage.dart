// ignore_for_file: library_private_types_in_public_api, no_logic_in_create_state, sort_child_properties_last, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_air/constants/Constantcolors.dart';
import 'package:on_air/screens/LandingPage/landingPage.dart';
import 'package:on_air/services/FirebaseOperations.dart';
import 'package:on_air/services/FirebaseOperations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../Chatroom/Chatroom.dart';
import '../Feed/Feed.dart';
import '../Profile/Profile.dart';
import 'HomepageHelper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConstantColors constantColors = ConstantColors();
  final PageController homepageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
     Provider.of<FirebaseOperations>(context, listen: false)
    .initUserData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
    return Scaffold(
        backgroundColor: constantColors.darkColor,
        body: PageView(
          controller: homepageController,
          children: [Feed(), Chatroom(), Profile()],
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (Page) {
            setState(() {
              pageIndex = Page;
            });
          },
        ),
        bottomNavigationBar: Provider.of<HomepageHelper>(context, listen: false)
            .bottomNavBar(context, pageIndex, homepageController));
  }
}
