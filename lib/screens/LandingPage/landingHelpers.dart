// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:on_air/screens/Homepage/Homepage.dart';
import 'package:on_air/screens/LandingPage/landingServices.dart';
import 'package:on_air/screens/LandingPage/landingUtils.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../../constants/Constantcolors.dart';

class LandingHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  Widget bodyImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          image:
              DecorationImage(image: AssetImage('assets\\images\\login.png'))),
    );
  }

  Widget taglineText(BuildContext context) {
    return Positioned(
        top: 530.0,
        left: 140.0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 170.0,
          ),
          child: RichText(
            text: TextSpan(
                text: "Next Gen ",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: constantColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Social Media ',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: constantColors.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 34.0),
                  ),
                  TextSpan(
                    text: 'App',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: constantColors.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 34.0),
                  )
                ]),
          ),
        ));
  }

  Widget mainButton(BuildContext context) {
    ConstantColors constantColors = ConstantColors();
    return Positioned(
        top: 710.0,
        child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    emailAuthSheet(context);
                  },
                  child: Container(
                    width: 80.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: constantColors.yellowColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Icon(EvaIcons.emailOutline,
                        color: constantColors.yellowColor),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('Singing with google');
                    Provider.of<Authentication>(context, listen: false)
                        .signInWithGoogle()
                        .whenComplete(() {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: HomePage(),
                              type: PageTransitionType.leftToRight));
                    });
                  },
                  child: Container(
                    width: 80.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: constantColors.blueColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child:
                        Icon(EvaIcons.google, color: constantColors.blueColor),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    width: 80.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: constantColors.redColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child:
                        Icon(EvaIcons.facebook, color: constantColors.redColor),
                  ),
                )
              ],
            )));
  }

  Widget privacyText(BuildContext context) {
    return Positioned(
      top: 850.0,
      left: 20.0,
      right: 20.0,
      child: Container(
        child: Column(
          children: [
            Text("By continuing you agree to our terms and conditions",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0)),
            Text("Thank you for using On-Air",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0))
          ],
        ),
      ),
    );
  }

  emailAuthSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150.0),
                  child: Divider(
                    color: constantColors.whiteColor,
                    thickness: 4.0,
                  ),
                ),
                Provider.of<LandindService>(context, listen: false)
                    .passwordLessSignIn(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        color: constantColors.redColor,
                        child: Text('Log in',
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Provider.of<LandindService>(context, listen: false)
                              .logInSheet(context);
                        }),
                    MaterialButton(
                        color: constantColors.blueColor,
                        child: Text('Sign up',
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Provider.of<LandingUtils>(context, listen: false)
                              .selectAvatarOptionsSheet(context);
                        })
                  ],
                )
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0))),
          );
        });
  }
}
