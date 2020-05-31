import 'package:flutter/material.dart';
import 'package:microlearning/classes/deck.dart';
import 'package:microlearning/helperFunctions/getDeckFromID.dart';
import 'package:microlearning/helperWidgets/flashCardView.dart';
import 'package:microlearning/screens/editdeck.dart';

class ViewDeck extends StatefulWidget {
  final String deckID;
  ViewDeck({Key key, @required this.deckID}) : super(key: key);
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
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context){return EditDecks(deck: deck);}));
              },
              child: Icon(
                Icons.edit,
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
    super.initState();
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
                print(currentPage);
                print(currentIndex);
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
