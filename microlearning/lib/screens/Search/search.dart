import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/searchService.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isSwitched = false; //Variable for the state of switch
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    var lowercasedValue = value.toLowerCase();

// Try accessing the IDs from here.
    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          final Map<dynamic, dynamic> element = {
            "deckName": docs.documents[i].data["deckName"],
            "tagsList": docs.documents[i].data["tagsList"],
            "flashcardList": docs.documents[i].data["flashcardList"],
            "isPublic": docs.documents[i].data["isPublic"],
            "deckNameLowerCase": docs.documents[i].data["deckNameLowerCase"],
            "searchKey": docs.documents[i].data["searchKey"],
            "deckID": docs.documents[i].documentID
          };
          //docs.documents[i].data;
          //element['deckID']= docs.documents[i].documentID;
          // print(element);
          queryResultSet.add(element);
          setState(() {
            tempSearchStore.add(element);
            // print(queryResultSet[i]['Name']);
          });
        }
      });
    } 
    else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['deckNameLowerCase'].startsWith(lowercasedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
        // print(QuerySnapshot docs.documents[element].documentID);
      });

      if (tempSearchStore.length == 0 && value.length > 1) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String state = isSwitched
        ? "Online Results"
        : "Offline Results"; //for user to see offline/online results
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('Search'),
        actions: <Widget>[
          Switch(
              activeColor: Colors.white,
              inactiveTrackColor: Colors.white30,
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  print(isSwitched);
                });
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (val) {
                print(val);
                initiateSearch(val);
              },
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.search),
                  iconSize: 20,
                  onPressed: () {},
                ),
                contentPadding: EdgeInsets.only(left: 25),
                hintText: "Search",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GridView.count(
            padding: EdgeInsets.only(left: 10, right: 10),
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            primary: false,
            shrinkWrap: true,
            children: tempSearchStore
                .map((element) => buildResultCard(context, element))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Try changing the widget that is being returned.
// Implementing the offline/online search is still left.
Widget buildResultCard(context, data) {
//  print(data);
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDeck(
              deckID: data['deckID'],
              editAccess: false,
            ),
          ));
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black)),
        child: Center(
          child: Text(
            data['deckName'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ),
    ),
  );
}
