import 'package:flutter/material.dart';
import 'package:microlearning/screens/accountsettings.dart';

class MyDecks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('FlashLearn'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AccountSettings();
                  },
              ),);
            },
          )
        ],
      ),
      body: Center(
        child: Text('My Decks'),
      ),
    );
  }
}