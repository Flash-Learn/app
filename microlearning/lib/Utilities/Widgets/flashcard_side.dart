import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:photo_view/photo_view.dart';

class FlashcardSide extends StatelessWidget {
  final bool isPic;
  final String content;
  final bool userRemembers;
  final bool editAccess;
  final bool isDeckForGrp;
  final bool isSmallView;

  FlashcardSide({
    this.isDeckForGrp,
    this.editAccess,
    this.userRemembers,
    this.isPic,
    this.content,
    this.isSmallView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      decoration: BoxDecoration(
          color: MyColorScheme.flashcardColor(),
          border: Border.all(
              color: !editAccess ? MyColorScheme.uno() : userRemembers
                  ? Color.fromRGBO(166, 250, 165, 1)
                  : Color.fromRGBO(250, 165, 165, 1),
              width: 4),
          borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: isPic
            ? ClipRect(
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
//                      print(constraints);
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.transparent, width: 3),
                        borderRadius: BorderRadius.circular(20)),
                    child: PhotoView(
                      minScale: PhotoViewComputedScale.contained,
                      imageProvider: NetworkImage(content),
                      backgroundDecoration:
                          BoxDecoration(color: Colors.transparent),
                      maxScale: PhotoViewComputedScale.covered * 2.0,
                      loadingBuilder: (BuildContext context,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) {
                          return Container();
                        }
                        return Center(
                          child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null),
                        );
                      },
                    ),
                  );
                }),
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
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: isSmallView ? 8 : 18,
                          fontWeight: FontWeight.normal),
                    ),
                    isPic
                        ? SizedBox()
                        : Container(
                            height: 50,
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
