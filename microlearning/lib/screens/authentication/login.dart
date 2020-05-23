import 'package:flutter/material.dart';
import 'package:microlearning/screens/authentication/register.dart';

class LoginUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(
              child: Text('NewUser? Register'),
              onPressed: () {
                return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return RegisterUser();}));
              },
            )
          ],
        ),
      ),
    );
  }
}