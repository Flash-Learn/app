import 'package:flutter/material.dart';
import 'package:microlearning/services/google_signIn.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/AccountManagement/edit_info.dart';

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Account Settings'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              color: Colors.black,
              child: InkWell(
                splashColor: Colors.grey,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditInfo()));
                },
                child: Container(
                  height: 40,
                  child: Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.transparent,
                    child: Center(
                      child: Text('Update Info',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Material(
              color: Colors.black,
              child: InkWell(
                splashColor: Colors.grey,
                onTap: () {
                  signOutGoogle();
                  return Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) {
                      return LoginUser();
                    }),
                    ModalRoute.withName('/login'),
                  );
                },
                child: Container(
                  height: 40,
                  child: Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.transparent,
                    child: Center(
                      child: Text('Log Out',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
