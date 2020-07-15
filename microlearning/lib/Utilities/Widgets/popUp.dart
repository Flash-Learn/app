import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

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

createAlertDialogLeaveGroup(BuildContext ctxt, String groupID) {
  return showDialog(
      context: ctxt,
      builder: (ctxt) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(ctxt).size.height * 0.2,
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Are you sure you want to leave this group?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(ctxt);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Leave',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        leaveGroup(groupID);
                        Navigator.pop(ctxt);
                        Navigator.of(ctxt).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) {
                          return GroupList();
                        }), (route) => false);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      });
}
