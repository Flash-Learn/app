import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/classes/username_signin.dart';
import 'package:microlearning/screens/authentication/get_user_info.dart';
import 'package:microlearning/screens/authentication/loadingscreen.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                        "Register New User",
                        style: TextStyle(
                          fontSize: 30,
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
                      GestureDetector(
                        onTap: () async {
                          if (_formkey.currentState.validate()) {
                            dynamic result =
                                await _auth.registerWithEmail(email, password);
                            if (result == null) {
                              setState(() {
                                error = 'Email not valid or already in use';
                              });
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return EmailVerification(
                                        email: email, uid: result.uid);
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
                            color: Colors.black,
                            child: Center(
                              child: Text('Register',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Row(
                      //   children: <Widget>[
                      //     Expanded(
                      //       child: GestureDetector(
                      //         onTap: () async {
                      //           // Register With Google Code
                      //         },
                      //         child: Container(
                      //           padding: EdgeInsets.only(right: 5),
                      //           height: 60,
                      //           child: Material(
                      //             borderRadius: BorderRadius.circular(5),
                      //             color: Colors.black,
                      //             child: Center(
                      //               child: Image(
                      //                 image:
                      //                     AssetImage("assets/google_logo.png"),
                      //                 height: 35.0,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: GestureDetector(
                      //         onTap: () async {
                      //           // Register With Facebook Code
                      //         },
                      //         child: Container(
                      //           padding: EdgeInsets.only(left: 5),
                      //           height: 60,
                      //           child: Material(
                      //             borderRadius: BorderRadius.circular(5),
                      //             color: Colors.black,
                      //             child: Center(
                      //               child: Image(
                      //                 image: AssetImage(
                      //                     "assets/facebook_logo_white.png"),
                      //                 height: 35.0,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      GestureDetector(
                        onTap: () {
                          return Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return LoginUser();
                          }));
                        },
                        child: Container(
                          height: 40,
                          child: Material(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.black,
                            child: Center(
                              child: Text('Log In',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
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

// googleRegisterinButton(BuildContext context) {
//   return OutlineButton(
//     splashColor: Colors.grey,
//     onPressed: () async {
//       String test = await signInWithGoogle(context);
//       if (test == null) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) {
//               return RegisterUser();
//             },
//           ),
//         );
//       } else {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) {
//               return GetUserInfo();
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
//               'Register With Google',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
