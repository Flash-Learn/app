import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/edit_info.dart';


class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Colors.red,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        icon: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              child:Text(
                'Update Info',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                )
              ),
              splashColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              borderSide: BorderSide(color: Colors.grey),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditInfo()));
              },
            ),
            SizedBox(height: 10.0,),
            OutlineButton(
              child: Text('Logout',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),),
              splashColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              borderSide: BorderSide(color: Colors.grey),
              onPressed: () {
                signOutGoogle();
                return Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context){
                    return LoginUser();
                  }),
                  ModalRoute.withName('/login'),
                );
              },
            ),
          ],
        )
      ),
    );
  }
}