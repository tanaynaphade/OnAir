import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:on_air/screens/Feed/FeedHelpers.dart';
import 'package:provider/provider.dart';

import '../../constants/Constantcolors.dart';

class Feed extends StatelessWidget {
  ConstantColors constantColor = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColor.blueGreyColor,
      appBar: Provider.of<FeedHelpers>(context, listen: false).appBar(context),
      body: Provider.of<FeedHelpers>(context, listen: false).feedBody(context),
    );
  }
}
