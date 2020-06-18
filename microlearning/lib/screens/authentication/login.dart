import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/Widgets/standard_button.dart';
import 'package:microlearning/Utilities/Widgets/standard_input_field.dart';

class Login extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              child: Column(
                children: <Widget>[
                  StandardInputField('Email'),
                  SizedBox(height: 20),
                  StandardInputField('Password'),
                  SizedBox(height: 20),
                  StandardButton(Text('Log In', style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 20),
                  StandardButton(Text('Register', style: TextStyle(color: Colors.white),))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}