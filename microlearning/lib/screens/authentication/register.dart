import 'package:flutter/material.dart';
import 'package:microlearning/classes/google_signin.dart';
import 'package:microlearning/classes/username_signin.dart';
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
      backgroundColor: Colors.blue[200],
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20,),
                    TextFormField(
                      validator: (val) {
                        return val.isEmpty ? 'Enter an Email' : null;
                      },
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
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
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      validator: (val) {
                         return val.length < 6 ? 'Length of password should be atleast 6 characters' : null;
                      },
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
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
                    ),
                    // SizedBox(height: 10,),
                    Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0),),
                    SizedBox(height: 20,),
                    OutlineButton(
                      child: Text('Register'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      borderSide: BorderSide(color: Colors.grey),
                      onPressed: () async{
                        if(_formkey.currentState.validate()){
                          dynamic result = await _auth.registerWithEmail(email,password);
                          if(result == null){
                            setState(() {
                              error = 'Please supply valid Email';
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
                    ),
                    SizedBox(height: 20,),
                    googleRegisterinButton(context),
                    SizedBox(height: 20,),
                    FlatButton(
                      child: Text('Existing User? Sign in.'),
                      onPressed: () {
                        return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {return LoginUser();}));
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
            return RegisterUser();
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
            child: Text('Register With Google',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          )
        ],
      ),
    ),
  );
}