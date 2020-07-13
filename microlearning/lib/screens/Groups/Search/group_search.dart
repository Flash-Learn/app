import 'dart:async';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/Utilities/Widgets/popUp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';
import 'package:microlearning/screens/Groups/group.dart';
import 'package:microlearning/Models/algolia.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

String _searchTerm;

class GroupSearch extends StatefulWidget {
  final GroupData groupData;
  GroupSearch({@required this.groupData});
  @override
  _GroupSearchState createState() => _GroupSearchState(groupData: groupData);
}

class _GroupSearchState extends State<GroupSearch> {
  bool isSwitched = false; //Variable for the state of switch
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  GroupData groupData;
  _GroupSearchState({@required this.groupData});

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("user_data").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  Widget buildResultCard(context, result) {
  return InkWell(
      onTap: () async {
        bool alreadyThere = false;
        bool doesExist = false;
        bool didAdd = false;
        CollectionReference userCollection =
            Firestore.instance.collection('user_data');
        try {
          var user = await userCollection
              .where("email", isEqualTo: result.data["email"])
              .getDocuments();
              print(result.data["email"]);
              print(groupData);
          user.documents.forEach((element) {
            doesExist = true;
            if (groupData.users.contains(element.documentID) == false) {
              groupData.users.add(element.documentID);
            } else {
              alreadyThere = true;
            }
          });
        } catch (e) {
          print(e);
          return;
        }
        if (!doesExist) {
          popUp(context, "No such user!");
          return;
        } else if (alreadyThere) {
          popUp(context, "User already in group!");
          return;
        }
        try {
          await updateGroupData(groupData);
        } catch (e) {
          print(e);
          return;
        }
        if (!didAdd) {
          popUp(context, "Some error occured. Try again!");
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              color: MyColorScheme.uno(),
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(
                          children: <Widget>[
                            Text(
                              result.data["name"],
                              style: TextStyle(
                                  color: MyColorScheme.cinco(),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
}


  @override
  Widget build(BuildContext context) {
    String state = isSwitched
        ? "Online Results"
        : "Offline Results"; //for user to see offline/online results
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: MyColorScheme.uno(),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: MyColorScheme.accent(),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text('Search',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: MyColorScheme.cinco())),
          actions: <Widget>[
            Switch(
                activeColor: MyColorScheme.accent(),
                inactiveTrackColor: MyColorScheme.accentLight(),
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    print(isSwitched);
                    print(state);
                  });
                }),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                enableSuggestions: true,
                onChanged: (val) {
                  setState(() {
                    _searchTerm = val;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.search),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                  contentPadding: EdgeInsets.only(left: 25),
                  hintText: "Search for a user",
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: MyColorScheme.accent(), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: MyColorScheme.accentLight(), width: 2.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text(
                    "",
                    style: TextStyle(color: Colors.black),
                  );
                else {
                  List<AlgoliaObjectSnapshot> currSearchStuff = snapshot.data;

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      else {
                        return Container(
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return _searchTerm.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 0.0),
                                      child: buildResultCard(
                                          context, currSearchStuff[index]),
                                    )
                                  : Container();
                            },
                            itemCount: currSearchStuff.length ?? 0,
                          ),
                        );
                      }
                  }
                }
              },
            ),
          ]),
        ));
  }
}

