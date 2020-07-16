import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/authentication/register.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(84, 205, 255, 1),
                Color.fromRGBO(84, 205, 255, 1),
                Color.fromRGBO(27, 116, 210, 1)
              ]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Image(
                //   image: AssetImage("assets/FlashLearn_Logo.png"),
                //   height: 100.0,
                // ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColorScheme.cinco(),
                  child: InkWell(
                    splashColor: MyColorScheme.accentLight(),
                    onTap: () async {
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(builder: (context){
                      //     return LoginUser();
                      // }));
                      _showbottomsheet(context, LoginUser());
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,
                        child: Center(
                          child: Text('Already a User?\nSign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColorScheme.cinco(),
                  child: InkWell(
                    splashColor: MyColorScheme.accentLight(),
                    onTap: () async {
                      // Navigator.of(context).pushReplacement(
                      //   MaterialPageRoute(builder: (context){
                      //     return LoginUser();
                      // }));
                      _showbottomsheet(context, RegisterUser());
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,
                        child: Center(
                          child: Text('New User?\nSign Up',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Container(
//                    width: MediaQuery.of(context).size.width * 0.7,
//                    height: 60,
//                    padding: const EdgeInsets.only(right: 0),
//                    child: Material(
//                      borderRadius: BorderRadius.circular(10),
//                      color: Colors.black,
//                      child: InkWell(
//                        splashColor: Colors.grey,
//                        onTap: () async {
//                          googleLoginButtonPress(context);
//                        },
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                          children: <Widget>[
//                            Text('Continue with Google', style: TextStyle(color: MyColorScheme.uno()),),
//                            Material(
//                              borderRadius: BorderRadius.circular(5),
//                              color: Colors.transparent,
//                              child: Center(
//                                child: Image(
//                                  image: AssetImage(
//                                      "assets/google_logo.png"),
//                                  height: 35.0,
//                                ),
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showbottomsheet(context, widget) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        builder: (BuildContext buildContext) {
          return SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Close',
                              style: TextStyle(color: MyColorScheme.accent()),
                            )),
                      ],
                    ),
                    widget,
                  ],
                )),
          );
        });
  }
}
