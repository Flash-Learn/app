import 'package:flutter/material.dart';
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
        centerTitle: true,
        title: Text('Reset Password'),
        backgroundColor: Colors.black,
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
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.grey),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(20.0),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0),
                            ),
                          ),
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
                          color: Colors.black,
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
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return LoginUser();
                                      },
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              height: 40,
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
