import 'package:firebase_auth/firebase_auth.dart';
import 'package:microlearning/classes/userclass.dart';

class UserNameSignIn {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool flag;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }
  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
      //.map((FirebaseUser user) => _userFromFirebaseUser(user));
      .map(_userFromFirebaseUser);
  }

  Future registerWithEmail(String email, String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      await user.sendEmailVerification();
      FirebaseUser tempuser = await _auth.currentUser();
      await tempuser.reload();
      tempuser = await _auth.currentUser();
      flag = tempuser.isEmailVerified;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signinWithEmail(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      if(!user.isEmailVerified){
        print('finally');
        return null;
      }else{
        return _userFromFirebaseUser(user);
      }
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future resetPassword(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      return 'email is right';
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future addUserData(String name, String gender, int grade) async {

  }

}