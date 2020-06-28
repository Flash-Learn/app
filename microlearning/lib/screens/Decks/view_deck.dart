import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/Utilities/functions/getDeckFromID.dart';
import 'package:microlearning/Utilities/functions/saveDeck.dart';
import 'package:microlearning/Utilities/Widgets/flashcardView.dart';
import 'package:microlearning/screens/Decks/edit_deck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
class ViewDeck extends StatefulWidget {
  final bool isdemo;
  final String deckID;
  final editAccess;
  final bool backAvailable;
  ViewDeck(
      {Key key,
      @required this.deckID,
      this.editAccess = true,
      this.backAvailable = true,
      this.isdemo = false})
      : super(key: key);
  @override
  _ViewDeckState createState() =>
      _ViewDeckState(deckID: deckID, isdemo: isdemo);
}

class _ViewDeckState extends State<ViewDeck> {
  bool showAllcards = true;
  bool isdemo;
  String deckID;
  Deck deck;
  _ViewDeckState({this.deckID, this.isdemo});

  // error here @samay
  GlobalKey<_FlashCardSwipeViewState> _keyFlashcard =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyEdit =
      GlobalKey<_FlashCardSwipeViewState>();
  GlobalKey<_FlashCardSwipeViewState> _keyshuffle =
      GlobalKey<_FlashCardSwipeViewState>();
  Offset _center;
  double _radius;
  bool _enabled = false;
  Widget _description;
  List<String> text = [
    'Click here to edit the deck',
    'Tap on the flash card to \n flip and view the other side',
    'Click here to shuffle the \n deck of flashcards',
  ];
  int _index = 0;

  spotlight(Key key) {
    Rect target = Spotlight.getRectFromKey(key);

    setState(() {
      _enabled = true;
      _center = _index == 1
          ? Offset(target.center.dx, target.center.dy)
          : Offset(target.center.dx, target.center.dy);
      _radius = _index == 1 ? Spotlight.calcRadius(target)*0.1 : Spotlight.calcRadius(target);
      _description = Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  text[_index],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColorScheme.uno()),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  maxLines: 2,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Material(
              color: MyColorScheme.accent(),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _enabled = false;
                      isdemo = false;
                    });
                  },
                  child: Text(
                    'SKIP demo!',
                    style: TextStyle(fontSize: 18, color: MyColorScheme.uno()),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            )
          ],
        ),
      );
    });
  }

  _ontap() async{
    _index++;
    if (_index == 1) {
      spotlight(_keyFlashcard);
    } else if( _index == 2){
      spotlight(_keyshuffle);
    }
    else {
      setState(() {
        _enabled = false;
      });
    }
  }

  @override
  void initState() {
//    deck = _getThingsOnStartup();
    super.initState();
    if (isdemo == true) {
      print('haha');
    }
    if(isdemo == true && _index == 0){
      Future.delayed(Duration(seconds: 1)).then((value) {
        spotlight(_keyEdit);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            Firestore.instance.collection("decks").document(deckID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("loading...");
          deck = Deck(
            deckName: snapshot.data["deckName"],
            tagsList: snapshot.data["tagsList"],
            isPublic: snapshot.data["isPublic"],
          );
          deck.deckID = deckID;
          deck.flashCardList = snapshot.data["flashcardList"];
          return Spotlight(
            enabled: _enabled,
            radius: _radius,
            description: _description,
            center: _center,
            onTap: () => _ontap(),
            animation: true,
            child: Scaffold(
            appBar: AppBar(
              backgroundColor: MyColorScheme.uno(),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: MyColorScheme.accent(),
                onPressed: () {
                  widget.editAccess ? Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MyDecks(),
                      ),
                      (Route<dynamic> route) => false)
                                    : Navigator.of(context).pop();
                },
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      size: 26.0,
                      color: MyColorScheme.accent(),
                    ),
                    onPressed: (){
                      setState(() {
                        showAllcards = !showAllcards;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    key: _keyshuffle,
                    icon: Icon(
                      Icons.shuffle,
                      size: 26.0,
                      color: MyColorScheme.accent(),
                    ),
                    onPressed: (){
                      setState(() {
                        deck.flashCardList.shuffle();
                      });
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      key: _keyEdit,
                      onTap: () {
                        if (widget.editAccess)
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return EditDecks(deck: deck);
                          }));
                        else {
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
                        color: MyColorScheme.accent(),
                      ),
                    ),
                  ),
              ],
              centerTitle: true,
              title: Text(
                deck.deckName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: MyColorScheme.cinco()),
              ),
            ),
            body: Container(
              key: _keyFlashcard,
              child: FlashCardSwipeView(
                deck: deck,
                showAllCards: showAllcards,
              ),
            ),
          )
        );
      },
    );
  }
}

class FlashCardSwipeView extends StatefulWidget {
  @override
  FlashCardSwipeView({
    this.deck,
    this.showAllCards,
  });
  final Deck deck;
  final bool showAllCards;
  _FlashCardSwipeViewState createState() =>
      _FlashCardSwipeViewState(deck: deck);
}

class _FlashCardSwipeViewState extends State<FlashCardSwipeView> {
  _FlashCardSwipeViewState({
    this.deck,
  });

  final Deck deck;
  PageController _pageCtrl = PageController(viewportFraction: 0.9);

  double currentPage = 0.0;

  Future<List<dynamic>> getNotRememberedCards() async {
      List<dynamic> ret = [];
      for (var cardID in deck.flashCardList){
        var document = Firestore.instance.collection('flashcards').document(cardID);
        await document.get().then((document) {
          dynamic tmp = document["userRemembers"];
          if(tmp == null || tmp == false)
            ret.add(cardID);
        });
      }

      return ret;
  }

  @override
  void initState() {
    // TODO: implement initState
    // TODO: implement initState
    super.initState();
    _pageCtrl.addListener(() {
      setState(() {
        currentPage = _pageCtrl.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if(widget.showAllCards) {
      return Container(
        color: Colors.white,
        child: PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.horizontal,
            itemCount: deck.flashCardList.length,
            itemBuilder: (context, int currentIndex) {
              return FlashCardView(
                color: Colors.accents[currentIndex],
                currentIndex: currentIndex,
                currentPage: currentPage,
                flashCardID: deck.flashCardList[currentIndex],
              );
            }),
      );
    }

    return FutureBuilder(
      future: getNotRememberedCards(),

      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot){

        if(!snapshot.hasData){
          return Loading(size: 50,);
        }

        List<dynamic> cardsNotRemembered = snapshot.data;
        return Container(
          color: Colors.white,
          child: PageView.builder(
              controller: _pageCtrl,
              scrollDirection: Axis.horizontal,
              itemCount: cardsNotRemembered.length,
              itemBuilder: (context, int currentIndex) {
//                print("${_pageCtrl.page}, $currentPage, $currentIndex");
//                if(currentIndex >= cardsNotRemembered.length){
//                  _pageCtrl.jumpToPage(0);
//                }
                try{
                  return FlashCardView(
                    color: Colors.accents[currentIndex],
                    currentIndex: currentIndex,
                    currentPage: currentPage,
                    flashCardID: cardsNotRemembered[currentIndex],
                  );
                } catch(e){
                  _pageCtrl.jumpToPage(0);
                }
                return Container();
              }),
        );
      }
    );

  }
}