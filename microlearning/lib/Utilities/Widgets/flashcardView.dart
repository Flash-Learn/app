import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCardView extends StatefulWidget {
  final Color color;
  final int currentIndex;
  final double currentPage;
  final String flashCardID;

  FlashCardView({
//    this.side,
    this.color,
    this.currentIndex,
    this.currentPage,
    this.flashCardID,
  });

  @override
  _FlashCardViewState createState() => _FlashCardViewState();
}

class _FlashCardViewState extends State<FlashCardView> {
  List<String> playListNames = <String>[];
  var _tapPosition;
  int side = 1;
  String term = "this is term";
  String definition =
      "this is definition, intentionally made long to make sure the text doesn't overflow in the flashcard";
  String display;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    display = term;
    side = 1;
  }

  @override
  Widget build(BuildContext context) {
    double relativePosition = widget.currentIndex - widget.currentPage;
     if ((widget.currentIndex - widget.currentPage).abs() >= 0.9) {

     }

    return StreamBuilder(
        stream: Firestore.instance
            .collection("flashcards")
            .document(widget.flashCardID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          term = snapshot.data["term"];
          definition = snapshot.data["definition"];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            child: Padding(
              key: ValueKey<int>(side),
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
              child: Container(
//          width: 200,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(1, 2, 0)
                    ..scale((1 - relativePosition.abs()).clamp(0.4, 0.6) + 0.4)
                    ..rotateY(relativePosition),
                  alignment: relativePosition >= 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,

                  child: Stack(
                    children:<Widget>[
                      FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: Stack(
                          children:<Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black, width: 3),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    term,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTapDown: (details) {
                                    _tapPosition = details.globalPosition;
                                  },
                                  onTap: ()async{
                                    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
                                    await showMenu(
                                      context: context,
                                      // found way to show delete button on the location of long press
                                      // not sure how it works
                                      position: RelativeRect.fromRect(
                                          _tapPosition & Size(40, 40), // smaller rect, the touch area
                                          Offset.zero & overlay.size // Bigger rect, the entire screen
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          value: "add to playlist",
                                          child: GestureDetector(
                                            onTap: () async{
                                              await _showbottomsheet(context);
                                            },
                                            child: Text("Add to playlists")
                                          ),
                                        ),
                                      ]
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0,10,20,0),
                                    child: Icon(Icons.more_horiz, color: Colors.black,),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        back: Stack(
                          children:<Widget>[
                              Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  border: Border.all(color: Colors.black, width: 3),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    definition,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTapDown: (details) {
                                    _tapPosition = details.globalPosition;
                                  },
                                  onTap: ()async{
                                    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
                                    await showMenu(
                                      context: context,
                                      // found way to show delete button on the location of long press
                                      // not sure how it works
                                      position: RelativeRect.fromRect(
                                          _tapPosition & Size(40, 40), // smaller rect, the touch area
                                          Offset.zero & overlay.size // Bigger rect, the entire screen
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          value: "add to playlist",
                                          child: GestureDetector(
                                            onTap: ()async{
                                              await _showbottomsheet(context); // function that makes the bottom sheet
                                            },
                                            child: Text("Add to playlists")
                                          ),
                                        ),
                                      ]
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0,10,20,0),
                                    child: Icon(Icons.more_horiz, color: Colors.white,),
                                  ),
                                )
                              ],
                            ),
                          ]
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
          );
        });
  }
  createAlertDialog(BuildContext ctxt){
    String playlistname;
    return showDialog(context: ctxt, builder: (ctxt){
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
            BorderRadius.circular(20.0)),
        child: Container(
          height: MediaQuery.of(ctxt).size.height * 0.2,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                onChanged: (newplaylist){
                  playlistname = newplaylist;
                },
                decoration: InputDecoration(
                  hintText: 'New PlayList',
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: (){
                      Navigator.pop(ctxt);
                    },
                  ),
                  FlatButton(
                    child: Text('Done'),
                    onPressed: (){
                      setState(() {
                        playListNames.add(playlistname);
                        // TODO: make a new playlist with name as playlistname variable
                      });
                      Navigator.pop(ctxt);
                      _showbottomsheet(context);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      );
    });
  }
  List<Widget> _buildlist(){
    // TODO: load data of playlist names in the playListNames list
    // I think we will require the playlist id's along with the playlist names
    // NOTE: Load the data for playlist here only
    int i;
    String k;
    i = 0;
    return playListNames.map<Widget>((String playlistID){
      i++;
      k = '$i';
      return ListTile(
        onTap: (){
          // TODO: add the flashcard to the playlist
          // Def: a playlist will be a deck of different flashcards
        },
        title: Text(playlistID),
        );
    }).toList();
  }
  void _showbottomsheet(context){
    List<Widget> children = _buildlist();
    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(icon: Icon(Icons.add),onPressed: (){
            Navigator.pop(context);
            createAlertDialog(context);
          },)
        ],
      )
    );
    showModalBottomSheet(context: context, builder: (BuildContext buildcon){
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      );
    });
  }
}
