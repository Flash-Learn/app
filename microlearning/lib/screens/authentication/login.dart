import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/classes/username_signin.dart';
import 'package:microlearning/helperFunctions/database.dart';
import 'package:microlearning/screens/authentication/get_user_info.dart';
import 'package:microlearning/screens/authentication/register.dart';
import 'package:microlearning/screens/authentication/resetpassword.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
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
                                BorderSide(color: Colors.white, width: 2.0),
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
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(20.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
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
                      SizedBox(
                        height: 20,
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () async {
                            if (_formkey.currentState.validate()) {
                              dynamic result =
                                  await _auth.signinWithEmail(email, password);
                              if (result == null) {
                                setState(() {
                                  error =
                                      'Wrong Credentials or Email not verified';
                                });
                              } else {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('email', email);
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
                            height: 40,
                            child: Material(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.transparent,
                              child: Center(
                                child: Text('Log In',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.only(right: 10),
                              child: Material(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                                child: InkWell(
                                  splashColor: Colors.grey,
                                  onTap: () async {
                                    String test =
                                        await signInWithGoogle(context);
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String uid = prefs.getString('uid');
                                    DataBaseServices here =
                                        DataBaseServices(uid: uid);
                                    List<String> defaults =
                                        await here.getData();
                                    if (here == null || defaults.length == 1) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return GetUserInfo();
                                          },
                                        ),
                                      );
                                    } else if (test == null) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return LoginUser();
                                          },
                                        ),
                                      );
                                    } else {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return MyDecks();
                                          },
                                        ),
                                      );
                                    }
                                    // signInWithGoogle().whenComplete(() {
                                    //   Navigator.of(context).pushReplacement(
                                    //     MaterialPageRoute(
                                    //       builder: (context) {
                                    //         return MyDecks();
                                    //       },
                                    //     ),
                                    //   );
                                    // });
                                  },
                                  child: Material(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Image(
                                        image: AssetImage(
                                            "assets/google_logo.png"),
                                        height: 35.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                                child: InkWell(
                                  splashColor: Colors.grey,
                                  onTap: () async {},
                                  child: Material(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Image(
                                        image: AssetImage(
                                            "assets/facebook_logo_white.png"),
                                        height: 35.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Material(
                        color: Colors.black,
                        child: InkWell(
                          splashColor: Colors.grey,
                          onTap: () {
                            return Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                              return RegisterUser();
                            }));
                          },
                          child: Container(
                            height: 40,
                            child: Material(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.transparent,
                              child: Center(
                                child: Text('Sign Up',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     Text(
                      //       'New User ?'
                      //     ),
                      //     SizedBox(width: 5,),
                      //     InkWell(
                      //   onTap: (){
                      //     return Navigator.of(context).pushReplacement(
                      //     MaterialPageRoute(builder: (context) {
                      //   return RegisterUser();
                      // }));
                      //   },
                      //       child: Text('Register'),
                      //     )
                      //   ],
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

// The below function is not needed. The onPressed method is in the onTap method of the above Gesture Detector

// googleRegisterinButton(BuildContext context) {
//   return OutlineButton(
//     splashColor: Colors.grey,
//     onPressed: () async {
//       String test = await signInWithGoogle(context);
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String uid = prefs.getString('uid');
//       DataBaseServices here = DataBaseServices(uid: uid);
//       List<String> defaults = await here.getData();
//       if (here == null || defaults.length == 1) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) {
//               return GetUserInfo();
//             },
//           ),
//         );
//       } else if (test == null) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) {
//               return LoginUser();
//             },
//           ),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) {
//               return MyDecks();
//             },
//           ),
//         );
//       }
//       // signInWithGoogle().whenComplete(() {
//       //   Navigator.of(context).pushReplacement(
//       //     MaterialPageRoute(
//       //       builder: (context) {
//       //         return MyDecks();
//       //       },
//       //     ),
//       //   );
//       // });
//     },
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//     borderSide: BorderSide(color: Colors.grey),
//     child: Padding(
//       padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Image(
//             image: AssetImage("assets/google_logo.png"),
//             height: 35.0,
//           ),
//           Padding(
//             padding: EdgeInsets.only(left: 10),
//             child: Text(
//               'Sign In with Google',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
