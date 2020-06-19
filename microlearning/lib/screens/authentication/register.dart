import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/Widgets/standard_button.dart';
import 'package:microlearning/Utilities/Widgets/standard_input_field.dart';
import 'package:microlearning/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/FlashLearn_Logo.png"),
                    height: 100.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "Flash Learn",
                          style: TextStyle(
                            fontSize: 45,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'Email'),
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (val) =>
                        val.length < 6 ? 'Enter Password 6+ chars long' : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.black,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {});
                          dynamic result =
                              await _auth.registerWithEmail(email, password);
                          if (result == null) {
                            setState(() {
                              error = 'Please enter a valid email';
                            });
                          }
                        }
                      }),
                  SizedBox(height: 20),
                  RaisedButton(
                      onPressed: () {
                        widget.toggleView();
                      },
                      color: Colors.black,
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
