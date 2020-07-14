import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

popUp(dynamic context, String res) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          title: Text("Sorry! Try again"),
          content: Text(res),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

popUpGood(dynamic context, String res) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          title: Text(
            "Yayy!",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          content: Text(
            res,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Ok",
                style: TextStyle(color: MyColorScheme.accent(), fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
