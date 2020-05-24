import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/screens/mydecks.dart';

class RegisterUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              googleSigninButton(context),
            ],
          ),
        ),
      ),
    );
  }
}

googleSigninButton(BuildContext context) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () async {
    String test = await signInWithGoogle(context);
    if(test == null){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return RegisterUser();
          },
        ),
      );
    }else{
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(image: AssetImage("assets/google_logo.png"),height: 35.0,),
          Padding(
            padding: EdgeInsets.only(left:10),
            child: Text('Sign in with Google',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          )
        ],
      ),
    ),
  );
}