import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  int side=1;
  String term = "this is term";
  String definition = "this is definition";
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

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
          child: Container(
//          width: 200,
            child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003)
                  ..scale((1-relativePosition.abs()).clamp(0.2, 0.6)+0.4)
                  ..rotateY(relativePosition),

                alignment: relativePosition >= 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,

                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      print("sf");
                      side = (side+1)%2 + 1;
                      if(side==1)
                        display=term;
                      else
                        display=definition;
                    });
                  },
                  child: Container(
                    color: side == 1
                        ? widget.color
                        : Colors.black45,
                    child: Center(
                      child: Text(
                        display,
//                  textAlign: TextAlign.center,
                      ),
                    ),
              ),
                ),
            ),
          ),
        ),
      );
    }
}
