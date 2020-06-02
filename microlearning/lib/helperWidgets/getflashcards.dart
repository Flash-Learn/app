import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';

class GetFlashCardEdit extends StatefulWidget {
  final Deck deck;
  GetFlashCardEdit({Key key, @required this.deck}): super(key: key);
  @override
  _GetFlashCardEditState createState() => _GetFlashCardEditState(deck: deck);
}

class _GetFlashCardEditState extends State<GetFlashCardEdit> {
  Deck deck;
  _GetFlashCardEditState({@required this.deck});

  int fieldCount = 0;
  int nextIndex = 0;
  List<List<TextEditingController>> controllers = [<TextEditingController>[]]; 

  List<List<String>> flashCardData = [<String>[]];
  
  // building own list of tags, cozz listview builder too much bt
  List<Widget> _buildList() { 
    int i;
    // fill in keys if the list is not long enough (in case one key is added)
    if (controllers.length < fieldCount) {
      for (i = controllers.length; i < fieldCount; i++) {
        controllers.add([TextEditingController(), TextEditingController()]);
        // print(controllers.length);
        controllers[i][0].text = flashCardData[i][0];
        controllers[i][1].text = flashCardData[i][1];
      }
    }
    print('${controllers.length} haha');
    i = 0;
    return controllers.map<Widget>((List<TextEditingController> controller){
      i++;
      if(controllers.indexOf(controller) == 0){
        return Padding(padding: EdgeInsets.zero,);
      }else{
        return Padding(
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
    children.add(
      IconButton(
        icon: Icon(Icons.add),
        onPressed: (){
          setState(() {
            fieldCount++;
            flashCardData.add(['','']);
          });
        },
      ),
    );

    // build the ListView
    return ReorderableListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
//      shrinkWrap: true,
      children: children,
      onReorder: (a, b){},
    );
  }

  void initState(){
    print(controllers.length);
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    flashCardData.add(['Mitochondria', 'It is powerhouse of the cell']);
    fieldCount = flashCardData.length;
    super.initState();
  }
}