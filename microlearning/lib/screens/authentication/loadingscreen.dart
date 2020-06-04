import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:microlearning/screens/authentication/get_user_info.dart';
import 'package:microlearning/screens/authentication/register.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerification extends StatefulWidget {
  final String email;
  final String uid;
  EmailVerification({Key key, @required this.email, @required this.uid}) : super(key: key);
  @override
  _EmailVerificationState createState() => _EmailVerificationState(email: email);
}

class _EmailVerificationState extends State<EmailVerification> {
  bool isUserEmailVerified;
  Timer timer;
  String email;
  String uid;

  _EmailVerificationState({this.email, this.uid});

  @override
  void initState(){
    super.initState();
    Future(() async {
        timer = Timer.periodic(Duration(seconds: 5), (timer) async {
            await FirebaseAuth.instance.currentUser()..reload();
            var user = await FirebaseAuth.instance.currentUser();
            // setState(() {
            //   email = user.email;
            // });
            if (user.isEmailVerified) {  
              isUserEmailVerified = user.isEmailVerified;
              SharedPreferences prefs = await SharedPreferences.getInstance(); 
              prefs.setString('email', user.email);
              prefs.setString('uid', user.uid);
              prefs.setBool('googlesignin', false);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return GetUserInfo();}));
              timer.cancel();
            }
        });
    });
  }
  @override
  void dispose() {
    print('disposed');
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitFoldingCube(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black)
                    ),
                  );
                },
              ),
              SizedBox(height: 20,),
              Text('An email verification link has been sent to $email \n Please verify.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold,),),
              SizedBox(height: 20,),
              Material(
                color: Colors.black,
                              child: InkWell(
                                splashColor: Colors.grey,
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {return RegisterUser();}));;
                  },
                  child: Container(
                    height: 40,
                    child: Material(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.transparent,
                      child: Center(
                        child: Text('Email not right? Change',
                            style: TextStyle(fontSize: 14, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}