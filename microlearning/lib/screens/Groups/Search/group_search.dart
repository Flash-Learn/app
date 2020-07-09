import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class GroupSearch extends StatefulWidget {
  @override
  _GroupSearchState createState() => _GroupSearchState();
}

class _GroupSearchState extends State<GroupSearch> {
  String _searchTerm;

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                  hintText: "Search for a group",
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
          ],
        ),
      ),
    );
  }
}
