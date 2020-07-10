import 'dart:async';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:microlearning/Models/algolia.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class GroupSearch extends StatefulWidget {
  @override
  _GroupSearchState createState() => _GroupSearchState();
}

class _GroupSearchState extends State<GroupSearch> {
  bool isSwitched = false; //Variable for the state of switch
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("user_data").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
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
                  hintText: "Search for a deck",
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
                    "Start Typing",
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

Widget buildResultCard(context, result) {
  return InkWell(
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
