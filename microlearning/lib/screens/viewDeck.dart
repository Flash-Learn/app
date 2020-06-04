import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';
import 'package:microlearning/helperFunctions/saveDeck.dart';
import 'package:microlearning/helperWidgets/flashCardView.dart';
import 'package:microlearning/screens/editdeck.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/screens/mydecks.dart';

class ViewDeck extends StatefulWidget {
  final String deckID;
  final editAccess;
  final bool backAvailable;
  ViewDeck({Key key, @required this.deckID, this.editAccess=true, this.backAvailable=true}) : super(key: key);
  @override
  _ViewDeckState createState() => _ViewDeckState(deckID: deckID);
}

class _ViewDeckState extends State<ViewDeck> {
  String deckID;
  Deck deck;
  _ViewDeckState({this.deckID});
  @override
  void initState(){
    deck = _getThingsOnStartup();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          body: FlashCardSwipeView(
            deck: deck,
          ),
        );
      },
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
