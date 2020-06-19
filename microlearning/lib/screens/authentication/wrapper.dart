import 'package:microlearning/models/user.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/screens/authentication/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    //return either home or authenticate
    if (user == null){
      return Authenticate();
    }
    else{
      print(user);
      return MyDecks();
    }
  }
}