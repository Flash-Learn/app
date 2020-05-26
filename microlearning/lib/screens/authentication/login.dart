import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/classes/username_signin.dart';
import 'package:microlearning/screens/authentication/register.dart';
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
      backgroundColor: Colors.blue[200],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                            ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink, width: 2.0),
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
                      SizedBox(height: 20,),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Password',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                            ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink, width: 2.0),
                            ),
                        ),
                        validator: (val) {
                           return val.length < 6 ? 'Length of password should be atleast 6 characters' : null;
                        },
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                      ),
                      //SizedBox(height: 10,),
                      Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0),),
                      SizedBox(height: 20,),
                      OutlineButton(
                        onPressed: () async{
                          if(_formkey.currentState.validate()){
                            dynamic result = await _auth.signinWithEmail(email, password);
                            if(result == null){
                              setState(() {
                                error = 'Username and Password do not Match';
                              });
                            }else{
                              SharedPreferences prefs = await SharedPreferences.getInstance(); 
                              prefs.setString('email', email);
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
                        child: Text('Sign In'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      SizedBox(height: 20,),
                      googleRegisterinButton(context),
                      SizedBox(height: 20,),
                      FlatButton(
                        child: Text('NewUser? Register'),
                        onPressed: () {
                          return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return RegisterUser();}));
                        },
                      )
                    ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

googleRegisterinButton(BuildContext context) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () async {
    String test = await signInWithGoogle(context);
    if(test == null){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return LoginUser();
          },
        ),
      );
    }else {
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
            child: Text('SignIn With Google',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          )
        ],
      ),
    ),
  );
}