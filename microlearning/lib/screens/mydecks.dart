// import 'dart:html';

import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperWidgets/deckInfoCard.dart';
import 'package:microlearning/screens/accountsettings.dart';
import 'package:microlearning/screens/viewDeck.dart';
import 'package:microlearning/helperFunctions/post.dart';

class MyDecks extends StatelessWidget {
  // TODO: "provide" User class object using provider

  final List<String> userDeckIDs = ["test string", "this will be a deck id"];
  // TODO: make method to get list of deck ID of user

  Widget buildDeckInfo(BuildContext ctxt, int index) {
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
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/search',
                );
              },
            ),
          ],
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
                ),
              );
            },
          )),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Container(
              height: 650,
              child: ListView.builder(
                itemCount: userDeckIDs.length,
                itemBuilder: (BuildContext ctxt, int index) => InkWell(
                    onTap: () {
                      print(userDeckIDs[index]);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewDeck(
                              deckID: userDeckIDs[index],
                            ),
                          ));
                    },
                    child: buildDeckInfo(ctxt, index)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
