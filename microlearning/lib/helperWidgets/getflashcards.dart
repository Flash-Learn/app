

import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';

class GetFlashCardEdit extends StatefulWidget {
  final List<List<String>> flashCardData;
  final Deck deck;

  GetFlashCardEdit({Key key, @required this.deck, @required this.flashCardData})
      : super(key: key);
  @override
  _GetFlashCardEditState createState() =>
      _GetFlashCardEditState(deck: deck, flashCardData: flashCardData);
}

class _GetFlashCardEditState extends State<GetFlashCardEdit> {
  List<List<String>> flashCardData;
  Deck deck;
  _GetFlashCardEditState({@required this.deck, @required this.flashCardData});

  int fieldCount = 0;
  int nextIndex = 0;
  List<List<TextEditingController>> controllers = [<TextEditingController>[]];

  // building own list of tags, cozz listview builder too much bt
  List<Widget> _buildList() {
    int i;
    String k;
    // fill in keys if the list is not long enough (in case one key is added)
    if (controllers.length < fieldCount) {
      for (i = controllers.length; i < fieldCount; i++) {
        controllers.add([TextEditingController(), TextEditingController()]);
        // print(controllers.length);
        controllers[i][0].text = flashCardData[i][0];
        controllers[i][1].text = flashCardData[i][1];
      }
    }
    i = 0;
    return controllers.map<Widget>(
      (List<TextEditingController> controller) {
        i++;
        k = '$i';
        print(k);
        if (controllers.indexOf(controller) == 0) {
          return Padding(
            key: ValueKey(k),
            padding: EdgeInsets.zero,
          );
        } else {
          return Dismissible(
            key: ValueKey(k),
            onDismissed: (direction) {
              setState(() {
                flashCardData.removeAt(controllers.indexOf(controller));
                controllers.remove(controller);
                fieldCount--;
              });
            },
            background: Container(
              color: Colors.grey,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  key: ValueKey(k),
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[900]),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                                maxLength: 20,
                                textAlign: TextAlign.center,
                                controller: controller[0],
                                onChanged: (val) {
                                  flashCardData[controllers.indexOf(controller)]
                                      [0] = val;
                                },
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                decoration: InputDecoration(
                                  counterText: '',
                                  // suffix: IconButton(
                                  //   icon: Icon(Icons.delete_outline),
                                  //   onPressed: (){
                                  //     setState(() {
                                  //       flashCardData.removeAt(controllers.indexOf(controller));
                                  //       controllers.remove(controller);
                                  //       fieldCount--;
                                  //     });
                                  //   },
                                  // ),
                                  hintText: 'Term',
                                  hintStyle: (TextStyle(color: Colors.grey)),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 0, top: 11, right: 15),
                                )),
                            Divider(
                              color: Colors.white,
                              endIndent: 20,
                              indent: 20,
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: <Widget>[
                            //     Text('---------------------------------'),
                            //     IconButton(
                            //       icon: Icon(Icons.delete_outline),
                            //       onPressed: (){
                            //         setState(() {
                            //           flashCardData.removeAt(controllers.indexOf(controller));
                            //           controllers.remove(controller);
                            //           fieldCount--;
                            //         });
                            //       },
                            //     ),
                            //   ],
                            // ),
                            TextFormField(
                              maxLines: null,
                              textAlign: TextAlign.center,
                              controller: controller[1],
                              style: TextStyle(color: Colors.white),
                              onChanged: (val) {
                                flashCardData[controllers.indexOf(controller)]
                                    [1] = val;
                              },
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: 'Definition',
                                hintStyle: (TextStyle(color: Colors.grey)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 15, bottom: 11, top: 0, right: 15),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            flashCardData
                                .removeAt(controllers.indexOf(controller));
                            print(flashCardData.length);
                            controllers.remove(controller);
                            fieldCount--;
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    // generate the list of TextFields
    final List<Widget> children = _buildList();
    // append an 'add player' button to the end of the list

    // build the ListView
    return Column(
//      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          key: ValueKey('issue is resolved now'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add,
                size: 40,
                color: Colors.black,
              ),
              Text(
                "Add flash card",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          onPressed: () {
            setState(() {
              fieldCount++;
              flashCardData.add(['', '']);
              //TODO: generate a id for flash card....But I don't think we will need this
            });
          },
        ), 
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 500,
          ),
          child: Scrollbar(
            child: ReorderableListView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
              children: children,
              key: Key(deck.deckName),
              onReorder: _onReorder,
            ),
          ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final List<String> item = flashCardData.removeAt(oldIndex);
      final List<TextEditingController> control =
          controllers.removeAt(oldIndex);
      //final String flashkey = deck.flashCardList.removeAt(oldIndex);
      controllers.insert(newIndex, control);
      flashCardData.insert(newIndex, item);
    });
  }

  @override
  void initState() {
    super.initState();
    print("length recieved ${flashCardData.length}");
    fieldCount = flashCardData.length;
    super.initState();
  }
}
