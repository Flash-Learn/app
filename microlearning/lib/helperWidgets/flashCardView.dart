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
    // if ((widget.currentIndex - widget.currentPage).abs() >= 0.9) {
    //   setState(() {
    //     side = 1;
    //   });
    // }

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

                  child: FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    front: Container(
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    back: Container(
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
                  ),
                ),
              ),
            ),
          );
        });
  }
}
