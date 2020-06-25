import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
class PlayListManage extends StatefulWidget {
  @override
  _PlayListManageState createState() => _PlayListManageState();
}

class _PlayListManageState extends State<PlayListManage> {
  List<String> playListNames = <String>[];
  List<Widget> children;
  var _tapPosition;
  bool _disableTouch = false;
  @override
  Widget build(BuildContext context) {
    children = _buildlist(context);
    children.insert(0, 
      Card(
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          leading: Icon(
            Icons.add,
            size: 40,
            color: MyColorScheme.accent(),
          ),
          title: Text('Add New PlayList', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          onTap: (){
            createAlertDialog(context);
          },
        ),
      ),
    );
    return AbsorbPointer(
      absorbing: _disableTouch,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: MyColorScheme.uno(),
          centerTitle: true,
          title: Text(
            'My Playlists',
            style: TextStyle(
                color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: MyColorScheme.accent(),),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              color: MyColorScheme.accent(),
              onPressed: (){
                showhelpdialog(context);
              },
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).size.height * 0.1),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                // TODO: setup a stream to load the playlists in the list of playListNames, I think we will need playlist ID's also, so set up a list of list(2-D)
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> _buildlist(BuildContext context){
    int i = 0;
    String k;
    return playListNames.map<Widget>((String playlistID) {
      i++;
      k = '$i';
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Stack(
          children: <Widget>[
            Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(20),
                leading: Icon(
                  Icons.playlist_play,
                  size: 40,
                  color: MyColorScheme.accent(),
                ),
                title: Text(playlistID, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                onTap: (){
                  //open the playlist
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0,10,15,0),
                  child: GestureDetector(
                    onTapDown: (details) {
                      _tapPosition = details.globalPosition;
                    },
                    onTap: () async{
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
                              value: "delete button",
                              child: GestureDetector(
                                onTap: () async{
                                  Navigator.pop(context, "delete button");
                                  setState(() {
                                    _disableTouch = true;
                                  });
                                  playListNames.remove(playlistID);
                                  setState(() {
                                    _disableTouch =false;
                                  });
                                },
                                child: Text("Delete")
                              ),
                            ),
                          ],
                          elevation: 8.0,
                        );
                    },
                    child: Icon(
                      Icons.more_horiz,
                      color: MyColorScheme.accent(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
  showhelpdialog(BuildContext ctxt){
    return showDialog(
      context: ctxt,
      builder: (ctxt) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(ctxt).size.height * 0.2,
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('PlayLists are collection of flashcards from different decks', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17,),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Done', style: TextStyle(color: MyColorScheme.accent()),),
                      onPressed: () {
                        setState(() {
                          // TODO: make a new playlist with name as playlistname variable
                        });
                        Navigator.pop(ctxt);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  createAlertDialog(BuildContext ctxt) {
    String playlistname;
    return showDialog(
      context: ctxt,
      builder: (ctxt) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(ctxt).size.height * 0.2,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  onChanged: (newplaylist) {
                    playlistname = newplaylist;
                  },
                  decoration: InputDecoration(
                    hintText: 'New PlayList',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(ctxt);
                      },
                    ),
                    FlatButton(
                      child: Text('Done'),
                      onPressed: () {
                        setState(() {
                          playListNames.add(playlistname);
                          // TODO: make a new playlist with name as playlistname variable
                        });
                        Navigator.pop(ctxt);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}