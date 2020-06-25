import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class ListofTags extends StatefulWidget {
  final Deck deck;
  ListofTags({Key key, @required this.deck}) : super(key: key);
  @override
  _ListofTagsState createState() => _ListofTagsState(deck: deck);
}

class _ListofTagsState extends State<ListofTags> {
  Deck deck;
  _ListofTagsState({@required this.deck});

  int fieldCount = 0;
  int nextIndex = 0;
  List<TextEditingController> controllers = <TextEditingController>[];

  // building own list of tags, cozz listview builder too much bt
  List<Widget> _buildList() {
    int i;
    // fill in keys if the list is not long enough (in case one key is added)
    if (controllers.length < fieldCount) {
      for (i = controllers.length; i < fieldCount; i++) {
        controllers.add(TextEditingController());
        controllers[i].text = deck.tagsList[i];
      }
    }
    i = 0;
    return controllers.map<Widget>(
      (TextEditingController controller) {
        i++;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: TextField(
            maxLength: 20,
            controller: controller,
            textAlign: TextAlign.center,
            onChanged: (val) {
              deck.tagsList[controllers.indexOf(controller)] =
                  val; // changing the value of the tag as indexed
            },
            decoration: InputDecoration(
              counterText: "",
              isDense: true,
              hintText: "Deck Tag",
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    fieldCount--; // decrementing the controller number
                    controllers.remove(controller); // removing the controller
                    deck.tagsList.remove(
                        controller.text); // removing the tag from the taglist
                  });
                },
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    // generate the list of TextFields
    final List<Widget> children = _buildList();

    // append an 'add player' button to the end of the list
    children.add(
      Container(
        margin: EdgeInsets.only(right: 250),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: MyColorScheme.accent(),
          child: InkWell(
            splashColor: Colors.grey,
            onTap: () {
              setState(() {
                fieldCount++;
                deck.tagsList.add('');
              });
            },
            child: Container(
              height: 40,
              child: Material(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: MyColorScheme.uno(),
                      ),
                      Text(
                        'Add Tag',
                        style: TextStyle(color: MyColorScheme.uno()),
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );

    // build the ListView
    return ListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
      shrinkWrap: true,
      children: children,
    );
  }

  @override
  void initState() {
    super.initState();

    // upon creation, copy the starting count to the current count
    fieldCount = widget.deck.tagsList.length;
  }
}
