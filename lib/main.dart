import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:on_air/constants/Constantcolors.dart';
import 'package:on_air/screens/AltProfile/alt_profile.dart';
import 'package:on_air/screens/AltProfile/alt_profile_helper.dart';
import 'package:on_air/screens/Chatroom/ChatroomHelper.dart';
import 'package:on_air/screens/Feed/FeedHelpers.dart';
import 'package:on_air/screens/Homepage/HomepageHelper.dart';
import 'package:on_air/screens/LandingPage/landingHelpers.dart';
import 'package:on_air/screens/LandingPage/landingServices.dart';
import 'package:on_air/screens/LandingPage/landingUtils.dart';
import 'package:on_air/screens/Messaging/GroupMessageHelper.dart';
import 'package:on_air/screens/Profile/ProfileHelpers.dart';
import 'package:on_air/screens/Splashscreen/splashScreen.dart';
import 'package:on_air/services/Authentication.dart';
import 'package:on_air/services/FirebaseOperations.dart';
import 'package:on_air/utils/PostOptions.dart';
import 'package:on_air/utils/UploadPost.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors = ConstantColors();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LandingHelpers()),
          ChangeNotifierProvider(create: (_) => Authentication()),
          ChangeNotifierProvider(create: (_) => LandindService()),
          ChangeNotifierProvider(create: (_) => FirebaseOperations()),
          ChangeNotifierProvider(create: (_) => LandingUtils()),
          ChangeNotifierProvider(create: (_) => HomepageHelper()),
          ChangeNotifierProvider(create: (_) => UploadPost()),
          ChangeNotifierProvider(create: (_) => FeedHelpers()),
          ChangeNotifierProvider(create: (_) => ProfileHelpers()),
          ChangeNotifierProvider(create: (_) => PostFuntions()),
          ChangeNotifierProvider(create: (_) => AltProfileHelper()),
          ChangeNotifierProvider(create: (_) => ChatroomHelper()),
          ChangeNotifierProvider(create: (_) => GroupMessageHelper()),
        ],
        child: MaterialApp(
          home: Splashscreen(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              accentColor: constantColors.blueColor,
              fontFamily: 'Poppins',
              canvasColor: Colors.transparent),
        ));
  }
}
