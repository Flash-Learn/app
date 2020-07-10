import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/services/username_signIn.dart';
import 'package:microlearning/screens/authentication/redirect.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _auth = UserNameSignIn();
  final _formkey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool passwordVisible;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // Image(
                //   image: AssetImage("assets/FlashLearn_Logo.png"),
                //   height: 100.0,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 45,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  ],
                ),
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
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        obscureText: passwordVisible,
                        decoration: inputTextDecorations('Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: MyColorScheme.cinco(),
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          return val.length < 6
                              ? 'Length of password should be atleast 6 characters'
                              : null;
                        },
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        obscureText: passwordVisible,
                        decoration:
                            inputTextDecorations('Re-Enter Password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: MyColorScheme.cinco(),
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val != password) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 50,
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColorScheme.accent(),
                          child: InkWell(
                            splashColor: MyColorScheme.accentLight(),
                            onTap: () async {
                              if (_formkey.currentState.validate()) {
                                dynamic result = await _auth.registerWithEmail(
                                    email.trim(), password);
                                if (result == null) {
                                  setState(() {
                                    error = 'Email not valid or already in use';
                                  });
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EmailVerification(
                                            email: email.trim(),
                                            uid: result.uid);
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
                                  child: Text('Register',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // SizedBox(
                      //   height: 20,
                      // ),

                      // Material(
                      //   color: Colors.black,
                      //   child: InkWell(
                      //     splashColor: Colors.grey,
                      //     onTap: () {
                      //       return Navigator.of(context).pushReplacement(
                      //           MaterialPageRoute(builder: (context) {
                      //         return LoginUser();
                      //       }));
                      //     },
                      //     child: Container(
                      //       height: 40,
                      //       child: Material(
                      //         borderRadius: BorderRadius.circular(5),
                      //         color: Colors.transparent,
                      //         child: Center(
                      //           child: Text('Log In',
                      //               style: TextStyle(
                      //                   fontSize: 14, color: Colors.white)),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
