import 'dart:async';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:microlearning/Models/algolia.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/screens/Decks/view_deck.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isSwitched = false; //Variable for the state of switch
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("decks").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    String state = isSwitched
        ? "Online Results"
        : "Offline Results"; //for user to see offline/online results
    return SafeArea(
      child: Scaffold(
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
                  hintText: "Search",
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
                                          vertical: 4.0, horizontal: 4.0),
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
        ),
      ),
    );
  }
}

Widget buildResultCard(context, result) {
  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDeck(
              deckID: result.data['deckID'],
              editAccess: false,
            ),
          ));
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: MyColorScheme.accent())),
        child: Container(
          height: 70,
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  result.data["deckName"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MyColorScheme.accent(),
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: getTags(result.data["tagsList"])),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

List<Widget> getTags(List<dynamic> strings) {
  List<Widget> ret = [];
  for (var i = 0; i < strings.length; i++) {
    ret.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: (i % 2 == 0)
            ? Color.fromRGBO(242, 201, 76, 1)
            : Color.fromRGBO(187, 107, 217, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          strings[i],
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            fontSize: 15,
          ),
        ),
      ),
    ));
    ret.add(SizedBox(
      width: 5,
    ));
  }
  return ret;
}
