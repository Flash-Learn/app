import 'package:microlearning/Utilities/constants/loading.dart';
import 'package:microlearning/screens/Decks/edit_flashcard.dart';
import 'flip_card.dart'; // created local copy of flip_card library
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

class FlashcardSide extends StatelessWidget {

  final bool isPic;
  final String content;

  dynamic _tapPosition;

  FlashcardSide({
    this.isPic,
    this.content,
});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: MyColorScheme.flashcardColor(),
          border: Border.all(
              color: MyColorScheme.flashcardColor(),
              width: 3),
          borderRadius: BorderRadius.circular(20)),
      child: Center(
        child:             isPic
                ? LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
//                      print(constraints);
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.transparent,
                                width: 3),
                            borderRadius: BorderRadius.circular(20)),
                        child: PhotoView(
                          minScale:
                          PhotoViewComputedScale
                              .contained,
                          imageProvider:
                          NetworkImage(
                              content
                          ),
                          backgroundDecoration:
                          BoxDecoration(
                              color: Colors
                                  .transparent),
                          maxScale:
                          PhotoViewComputedScale
                              .covered *
                              2.0,
                          loadingBuilder:
                              (BuildContext
                          context,
                              ImageChunkEvent
                              loadingProgress) {
                            if (loadingProgress ==
                                null) {
                              return Container();
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes
                                      : null),
                            );
                          },
                        ),
                      );
      }

                )
            // ? Image.network(definition,
            //     loadingBuilder:
            //         (BuildContext context,
            //             Widget child,
            //             ImageChunkEvent
            //                 loadingProgress) {
            //     if (loadingProgress == null)
            //       return child;
            //     return Center(
            //       child: CircularProgressIndicator(
            //         value: loadingProgress
            //                     .expectedTotalBytes !=
            //                 null
            //             ? loadingProgress
            //                     .cumulativeBytesLoaded /
            //                 loadingProgress
            //                     .expectedTotalBytes
            //             : null,
            //       ),
            //     );
            //   })
                :
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.normal),
              ),
              isPic ? SizedBox() : Container(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}
