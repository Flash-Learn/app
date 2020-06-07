import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/updateFlashcardList.dart';
import 'package:microlearning/helperWidgets/getflashcards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/viewDeck.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';

class EditFlashCard extends StatefulWidget {
  final Deck deck;
  final bool isdemo;
  EditFlashCard({Key key, @required this.deck, this.isdemo = false}): super(key: key);
  @override
  _EditFlashCardState createState() => _EditFlashCardState(deck: deck, isdemo: isdemo);
}

class _EditFlashCardState extends State<EditFlashCard> {
//  List<List<String>> flashCardDatatemp = [<String>[]];
  bool isdemo;
  Stream<dynamic> getCardfromDataBase;
  List<List<String>> flashCardData;
  Deck deck;
  _EditFlashCardState({@required this.deck, this.isdemo});
  Deck newDeck;

  static final GlobalKey<_EditFlashCardState> _keyFlashcard = GlobalKey<_EditFlashCardState>();
  static final GlobalKey<_EditFlashCardState> _keySave = GlobalKey<_EditFlashCardState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = ['Make changes to you flash card here', 'Click here to save your deck'];
  int _index = 0;

  spotlight(Key key){
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = _index == 0 ? Offset(target.center.dx, target.center.dy -150) : Offset(target.center.dx, target.center.dy);
      _radius = _index == 0 ? 100 :Spotlight.calcRadius(target);
      _description = Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text[_index],
              style:
                ThemeData.light().textTheme.caption.copyWith(color: Colors.white, fontSize: 35),
                textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            SizedBox(height: 20,),
            Material(
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _enabled = false;
                      isdemo = false;
                    });
                  },
                  child: Text(
                    'SKIP demo!', style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  _ontap(){
    _index++;
    if(_index == 1){
      spotlight(_keySave);
    }
    else{
      setState(() {
        _enabled = false;
      });
    }
  }
  

  @override
  initState(){
    super.initState();
    if(isdemo == true){
      print('haha');
      Future.delayed(Duration(seconds: 2)).then((value) {
        spotlight(_keyFlashcard);
      });
    }
    newDeck = deck;
    flashCardData = [<String>[]];

    getCardfromDataBase = (() async* {
//    await Future<void>.delayed(Duration(seconds: 1));
//    yield 1;
      // add the function to get the flashcards from database and save it in flashCardData, while retriving data from
      // the database make sure to initialise flashCardData as List<List<String>> flashCardData = [<String>[]],
      // this will make flashCardData[0] as null but it is the only way it is working and I made my code work according to this.
      final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");
//    print(newDeck.deckID);
      for(var i=0; i<newDeck.flashCardList.length; i++){

        print("flash card id: ${newDeck.flashCardList[i]}");
        await flashcardReference.document(newDeck.flashCardList[i]).get().then((ref){
          flashCardData.add([ref.data["term"], ref.data["definition"]]);
        });
      }
      flashCardData.add(['','']);
      print(flashCardData.length);
      print("yield go brrr");
      yield 1;
    })();
  }


  @override
  Widget build(BuildContext context) {
    return Spotlight(
      enabled: _enabled,
      radius: _radius,
      description: _description,
      center: _center,
      onTap: () => _ontap(),
      animation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
//      floatingActionButtonLocation: FloatingActionButtonLocation.rightFloat,
        floatingActionButton: FloatingActionButton.extended(
          key: _keySave,
          backgroundColor: Colors.black,
          icon: Icon(Icons.check),
          label: Text('Save Deck', style: TextStyle(fontSize: 15),),
          onPressed: ()async{
            // TODO: save the changes made by the user in the flash cards of the deck.
            // popping the current screen and taking the user back to the deck card info page.
            print("flashcarddata length: ${flashCardData.length}");
            await updateFlashcardList(deck, flashCardData);


            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (context) => ViewDeck(
                deckID: newDeck.deckID,
                backAvailable: false,
                isdemo: isdemo,
              ),
            ), (Route<dynamic> route) => false);

//          Navigator.pop(context);
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Edit Deck'),
          centerTitle: true,
//        actions: <Widget>[
//          Padding(
//            padding: EdgeInsets.only(right: 20.0),
//            child: GestureDetector(
//              onTap: (){
//                //TODO: submit the changes made by the user on the local storage as well as database and return to mydecks.
//              },
//              child: Icon(
//                Icons.done,
//                size: 26,
//              ),
//            ),
//          )
//        ],
        ),
        body: SingleChildScrollView(
          child: Column(
            key: _keyFlashcard,
            children: <Widget>[
              StreamBuilder<Object>(
                stream: getCardfromDataBase, // TODO: add the stream here for the getting the 2d array of the things
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(flashCardData.length-1 == newDeck.flashCardList.length+1 ){
                    // flashCardData.add(['','']);
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GetFlashCardEdit(deck: deck, flashCardData: flashCardData, ),
                    );
                  }
                  else{
                    return Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        width: 60,
                        height: 60,
                      ),
                    );
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

//  Stream<dynamic> getCardfromDataBase = (() async* {
////    await Future<void>.delayed(Duration(seconds: 1));
////    yield 1;
//    // add the function to get the flashcards from database and save it in flashCardData, while retriving data from
//    // the database make sure to initialise flashCardData as List<List<String>> flashCardData = [<String>[]],
//    // this will make flashCardData[0] as null but it is the only way it is working and I made my code work according to this.
//    final CollectionReference flashcardReference = Firestore.instance.collection("flashcards");
////    print(newDeck.deckID);
//    for(var i=0; i<newDeck.flashCardList.length; i++){
//
//      print("flash card id: ${newDeck.flashCardList[i]}");
//      flashcardReference.document(newDeck.flashCardList[i]).get().then((ref){
//        flashCardData.add([ref.data["term"], ref.data["definition"]]);
//      });
//    }
//
//    yield 1;
//  })();
}