import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String name;
String email;
String imageUrl;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
  
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    idToken: googleSignInAuthentication.idToken, 
    accessToken: googleSignInAuthentication.accessToken
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
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

  return 'SignInWithGoogle succeeded: $user';
} 
void signOutGoogle() async {
  await googleSignIn.signOut();
  print('User signed out');
}
