import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/services/username_signIn.dart';
import 'package:microlearning/screens/authentication/reset_password.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class LoginUser extends StatefulWidget {
  @override
  _LoginUserState createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                    "Sign In",
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
                  SizedBox(
                    height: 20,
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
                          color: MyColorScheme.accentLight(),
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
                  Container(
                      alignment: Alignment(1, 0),
                      padding: EdgeInsets.only(top: 15, left: 20),
                      child: InkWell(
                        child: Text('Forgot Password'),
                        onTap: () {
                          return Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ResetPassword();
                          }));
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColorScheme.accent(),
                        child: InkWell(
                          splashColor: MyColorScheme.accentLight(),
                          onTap: () async {
                            if (_formkey.currentState.validate()) {
                              dynamic result = await _auth.signinWithEmail(
                                  email.trim(), password);
                              if (result == null) {
                                setState(() {
                                  error =
                                      'Wrong Credentials or Email not verified';
                                });
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('email', email.trim());
                                prefs.setString('uid', result.uid);
                                prefs.setBool('googlesignin', false);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MyDecks();
                                    },
                                  ),
                                );
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
                                child: Text('Sign In',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Material(
                      //   borderRadius: BorderRadius.circular(10),
                      //   color: MyColorScheme.accent(),
                      //   child: InkWell(
                      //     splashColor: Colors.grey,
                      //     onTap: () {
                      //       return Navigator.of(context).pushReplacement(
                      //           MaterialPageRoute(builder: (context) {
                      //         return RegisterUser();
                      //       }));
                      //     },
                      //     child: Container(
                      //       height: 50,
                      //       width: MediaQuery.of(context).size.width * 0.4,
                      //       child: Material(
                      //         borderRadius: BorderRadius.circular(5),
                      //         color: Colors.transparent,
                      //         child: Center(
                      //           child: Text('Sign Up',
                      //               style: TextStyle(
                      //                   fontSize: 14, color: Colors.white)),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Container(
                  //         height: 60,
                  //         padding: const EdgeInsets.only(right: 0),
                  //         child: Material(
                  //           borderRadius: BorderRadius.circular(10),
                  //           color: Colors.black,
                  //           child: InkWell(
                  //             splashColor: Colors.grey,
                  //             onTap: () async {
                  //               googleLoginButtonPress(context);
                  //             },
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //               children: <Widget>[
                  //                 Text('Sign In With Google', style: TextStyle(color: MyColorScheme.uno()),),
                  //                 Material(
                  //                   borderRadius: BorderRadius.circular(5),
                  //                   color: Colors.transparent,
                  //                   child: Center(
                  //                     child: Image(
                  //                       image: AssetImage(
                  //                           "assets/google_logo.png"),
                  //                       height: 35.0,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  // Expanded(
                  //   child: Container(
                  //     height: 60,
                  //     padding: const EdgeInsets.only(left: 10.0),
                  //     child: Material(
                  //       borderRadius: BorderRadius.circular(5),
                  //       color: Colors.black,
                  //       child: InkWell(
                  //         splashColor: Colors.grey,
                  //         //TODO: add facebook login
                  //         onTap: () async {},
                  //         child: Material(
                  //           borderRadius: BorderRadius.circular(5),
                  //           color: Colors.transparent,
                  //           child: Center(
                  //             child: Image(
                  //               image: AssetImage(
                  //                   "assets/facebook_logo_white.png"),
                  //               height: 35.0,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // ],
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
