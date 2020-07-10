import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/screens/authentication/welcome.dart';
import 'package:microlearning/services/username_signIn.dart';
import 'package:microlearning/screens/authentication/login.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _auth = UserNameSignIn();
  final _formkey = GlobalKey<FormState>();

  String email = '';
  String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: Text('Reset Password', style: TextStyle(color: MyColorScheme.cinco()),),
        backgroundColor: MyColorScheme.uno(),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          color: MyColorScheme.accent(),
          icon: Icon(Icons.chevron_left),
          iconSize: 28,
        ),
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formkey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: inputTextDecorations('Email'),
                          validator: (val) {
                            return val.isEmpty ? 'Enter an Email' : null;
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Material(
                          color: MyColorScheme.accent(),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            splashColor: Colors.grey,
                            onTap: () async {
                              if (_formkey.currentState.validate()) {
                                dynamic result =
                                    await _auth.resetPassword(email);
                                if (result == null) {
                                  setState(() {
                                    error = 'Email not registered';
                                  });
                                } else {
                                  SnackBar snackBar = SnackBar(
                                    content: Text(
                                      'Reset password link sent to your mail',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                  await Future.delayed(Duration(seconds: 4));
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Material(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.transparent,
                                child: Center(
                                  child: Text('Enter',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
