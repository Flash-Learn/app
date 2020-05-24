import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/deckInfoCard.dart';
import 'package:microlearning/screens/accountsettings.dart';

class MyDecks extends StatelessWidget {

  // TODO: "provide" User class object using provider

  final List<String> userDeckIDs = ["test string", "this wil be a deck id"];
  // TODO: make method to get list of deck ID of user

  Widget buildDeckInfo(BuildContext ctxt, int index){
    return deckInfoCard(userDeckIDs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text('FlashLearn'),
        leading: IconButton(
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
        child: Center(
          child: ListView.builder(
            itemCount: userDeckIDs.length,
            itemBuilder: (BuildContext ctxt, int index) => buildDeckInfo(ctxt, index),
          ),
        ),
      ),
    );
  }
}