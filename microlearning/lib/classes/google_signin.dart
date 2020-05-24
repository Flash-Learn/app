import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

String name;
String email;
String imageUrl;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn().catchError((onError){Navigator.of(context).popAndPushNamed('/');},);

  if (googleSignInAccount == null){
    return null;
  }

  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
  
  if (googleSignInAuthentication == null){
    return null;
  }

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    idToken: googleSignInAuthentication.idToken, 
    accessToken: googleSignInAuthentication.accessToken
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);

  if(authResult == null){
    return null;
  }
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  
  final FirebaseUser currentUser = await _auth.currentUser();

  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;


  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }
  
  assert(user.uid == currentUser.uid);

  if(user!=null){
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    prefs.setString('email', email);
    prefs.setString('name', name);
  }

  return '$user';
} 
void signOutGoogle() async {
  await googleSignIn.signOut();
  SharedPreferences prefs = await SharedPreferences.getInstance(); 
  prefs.remove('name');
  prefs.remove('email');
  print('User signed out');
}
