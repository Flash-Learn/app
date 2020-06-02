import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';

class GetFlashCardEdit extends StatefulWidget {
  List<List<String>> flashCardData;
  final Deck deck;
  
  GetFlashCardEdit({Key key, @required this.deck, @required this.flashCardData}): super(key: key);
  @override
  _GetFlashCardEditState createState() => _GetFlashCardEditState(deck: deck, flashCardData: flashCardData);
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
    return controllers.map<Widget>((List<TextEditingController> controller){
      i++;
      k = '$i';
      print(k);
      if(controllers.indexOf(controller) == 0){
        return Padding(
            key: ValueKey(k),
            padding: EdgeInsets.zero,
          );
      }else{
        return Padding(
          key: ValueKey(k),
          padding: const EdgeInsets.all(20.0),
          child: Container(
            color: Colors.grey[800],
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: controller[0],
                    onChanged: (val){
                      flashCardData[controllers.indexOf(controller)][0] = val;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Term',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    )
                  ),
                  Divider(height: 20, color: Colors.white, indent: 10, endIndent: 10,),
                  TextFormField(
                    maxLines: null,
                    textAlign: TextAlign.center,
                    controller: controller[1],
                    style: TextStyle(color: Colors.white),
                    onChanged: (val){
                      flashCardData[controllers.indexOf(controller)][1] = val;
                    },
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Definition',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                    ),
                  )
                ],
              ),
            )
          ),
        );}
    },).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    // generate the list of TextFields
    final List<Widget> children = _buildList();
    // append an 'add player' button to the end of the list

    // build the ListView
    return Column(
      children: <Widget>[
        SizedBox(
          height: 500,
          child: Scrollbar(
            child: ReorderableListView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
              children: children,
              key: Key(deck.deckName),
              onReorder: _onReorder,
            ),
          ),
        ),
        IconButton(
        key: ValueKey('issue is resolved now'),
        icon: Icon(Icons.add),
        onPressed: (){
          setState(() {
            fieldCount++;
            flashCardData.add(['','']);
            //TODO: generate a id for flash card....But I don't think we will need this
          });
        },
      ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex){
    setState(() {
      if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final List<String> item = flashCardData.removeAt(oldIndex);
        final List<TextEditingController> control = controllers.removeAt(oldIndex);
        //final String flashkey = deck.flashCardList.removeAt(oldIndex);
        controllers.insert(newIndex, control);
        flashCardData.insert(newIndex, item);
    });
  }

  void initState(){
    // remove these lines
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    fieldCount = flashCardData.length;
    super.initState();
  }
}