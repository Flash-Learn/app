import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class NotificationInapp extends StatefulWidget {
  @override
  _NotificationInappState createState() => _NotificationInappState();
}

class _NotificationInappState extends State<NotificationInapp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: MyColorScheme.uno(),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColorScheme.accent(),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}