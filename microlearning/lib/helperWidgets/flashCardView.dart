import 'package:flutter/material.dart';

class FlashCardView extends StatelessWidget {

  final Color color;
  final int currentIndex;
  final double currentPage;
  final String flashCardID;

  FlashCardView({
    this.color,
    this.currentIndex,
    this.currentPage,
    this.flashCardID,
  });

  @override
  Widget build(BuildContext context) {
    double relativePosition = currentIndex - currentPage;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: color,
        width: 300,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.003)
            ..scale(0.5)
            ..rotateY(relativePosition),

          alignment: relativePosition >= 0
            ? Alignment.centerLeft
            : Alignment.centerRight,
        ),
      ),
    );
  }
}
