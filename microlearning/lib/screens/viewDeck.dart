import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';
import 'package:microlearning/helperFunctions/saveDeck.dart';
import 'package:microlearning/helperWidgets/flashCardView.dart';
import 'package:microlearning/screens/editdeck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';

class ViewDeck extends StatefulWidget {
  final bool isdemo;
  final String deckID;
  final editAccess;
  final bool backAvailable;
  ViewDeck({Key key, @required this.deckID, this.editAccess=true, this.backAvailable=true, this.isdemo = false}) : super(key: key);
  @override
  _ViewDeckState createState() => _ViewDeckState(deckID: deckID, isdemo: isdemo);
}

class _ViewDeckState extends State<ViewDeck> {
  bool isdemo;
  String deckID;
  Deck deck;
  _ViewDeckState({this.deckID, this.isdemo});


  static final GlobalKey<_FlashCardSwipeViewState> _keyFlashcard = GlobalKey<_FlashCardSwipeViewState>();
  static final GlobalKey<_FlashCardSwipeViewState> _keyEdit = GlobalKey<_FlashCardSwipeViewState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = ['Tap on the flash card to view the definition', 'Click here to edit the deck'];
  int _index = 0;

  spotlight(Key key){
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = _index == 0 ? Offset(target.center.dx, target.center.dy -300) : Offset(target.center.dx, target.center.dy);
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
      spotlight(_keyEdit);
    }
    else{
      setState(() {
        _enabled = false;
      });
    }
  }


  @override
  void initState(){
    deck = _getThingsOnStartup();
    super.initState();
    if(isdemo == true){
      print('haha');
      Future.delayed(Duration(seconds: 2)).then((value) {
        spotlight(_keyFlashcard);
      });
    }
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
      child: StreamBuilder(
        stream: Firestore.instance.collection("decks").document(deckID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Text("loading...");
          deck = Deck(
            deckName: snapshot.data["deckName"],
            tagsList: snapshot.data["tagsList"],
            isPublic: snapshot.data["isPublic"],
          );
          deck.deckID = deckID;
          deck.flashCardList = snapshot.data["flashcardList"];
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: widget.backAvailable ? null : IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,

                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) => MyDecks(),
                  ), (Route<dynamic> route) => false);
                },
              ),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      key: _keyEdit,
                      onTap: () {
                        if(widget.editAccess)
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){return EditDecks(deck: deck);}));
                        else{
                          print(deck.flashCardList.length);
                          saveDeck(context, deck);
                        }
                        setState(() {
                          print("called");
                        });
                      },
                      child: Icon(
                        widget.editAccess ? Icons.edit : Icons.file_download,
                        size: 26.0,
                      ),
                    )
                ),
              ],
              centerTitle: true,
              title: Text(
                deck.deckName,
              ),
            ),
            body: Container(
              key: _keyFlashcard,
              child: FlashCardSwipeView(
                deck: deck,
              ),
            ),
          );
        },
      ),
    );
  }
  Deck _getThingsOnStartup(){
    Deck deck = getDeckFromID(deckID);
    return deck;
  }
}

class FlashCardSwipeView extends StatefulWidget {
  @override
  FlashCardSwipeView({
    this.deck,
  });
  final Deck deck;
  _FlashCardSwipeViewState createState() => _FlashCardSwipeViewState(deck: deck);
}

class _FlashCardSwipeViewState extends State<FlashCardSwipeView> {

  _FlashCardSwipeViewState({
    this.deck,
  });
  final Deck deck;
  final PageController _pageCtrl = PageController(viewportFraction: 0.8);

  double currentPage = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    // TODO: implement initState
    super.initState();
//    refreshIndicatorKey.currentState.show();
    print("init");
    _pageCtrl.addListener(() {
//      print("sdfaf");
      setState(() {
        currentPage = _pageCtrl.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    int prevIndex=1;
    int side=1;
    return Container(
//            height: 500,
      color: Colors.white,
      child: PageView.builder(
        controller: _pageCtrl,
        scrollDirection: Axis.horizontal,
        itemCount: deck.flashCardList.length,
        itemBuilder: (context, int currentIndex) {
//                print(currentPage);
//                print(currentIndex);
//                print(deck.flashCardList[currentIndex]);
          return FlashCardView(
//                  side: side,
            color: Colors.accents[currentIndex],
            currentIndex: currentIndex,
            currentPage: currentPage,
            flashCardID: deck.flashCardList[currentIndex],
          );
        }
      ),
    );
}
}
