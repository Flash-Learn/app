import 'package:flutter/material.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';

class myDeckTitleBar extends StatelessWidget {

  final keySearch;
  myDeckTitleBar({this.keySearch});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 1,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('My Decks'),
        actions: <Widget>[
          IconButton(
            key: keySearch,
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
        )
    );
  }
}
