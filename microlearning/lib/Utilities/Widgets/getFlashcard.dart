import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:microlearning/Models/flashcard.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class GetFlashCardEdit extends StatefulWidget {
  final List<FlashCard> flashCardData;
  final Deck deck;
  final GlobalKey<ScaffoldState> scaffoldKey;

  GetFlashCardEdit(
      {Key key,
      @required this.deck,
      @required this.flashCardData,
      @required this.scaffoldKey})
      : super(key: key);
  @override
  _GetFlashCardEditState createState() =>
      _GetFlashCardEditState(deck: deck, flashCardData: flashCardData);
}

class _GetFlashCardEditState extends State<GetFlashCardEdit> {
  List<FlashCard> flashCardData;
  Deck deck;
  _GetFlashCardEditState({@required this.deck, @required this.flashCardData});

  int fieldCount = 0;
  int nextIndex = 0;
  ScrollController _scrollController = new ScrollController();
  final _picker = ImagePicker();

  // function for getting the image from the source (camera or gallery)
  getImage(ImageSource source, BuildContext context, int index, bool forTerm) async {
    final image = await _picker.getImage(
        source: source); // take the image from the source
    if (image != null) {
      // if the image is not null then take it to the cropping window
      final cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        // compressQuality: 50,
        // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxHeight: 500,
        maxWidth: 500,
        // maxWidth: (MediaQuery.of(context).size.width * 0.8).toInt(),
      );
      if (cropped != null) {
        // if the image received from the cropper is not null then upload it to the database
        String filename = basename(cropped.path);
        StorageReference firebaseStorageref =
            FirebaseStorage.instance.ref().child('images/$filename');
        StorageUploadTask uploadTask = firebaseStorageref.putFile(cropped);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        String url = (await taskSnapshot.ref.getDownloadURL()).toString();
        setState(() {
          if(forTerm){
            flashCardData[index].term = url;
            flashCardData[index].isTermPhoto = true;
          } else {
            flashCardData[index].isDefinitionPhoto = true;
            flashCardData[index].definition =
                url;
                } // saving the url into the list of flashcards
        });
      }
    }
  }

  _showSnackbar(String text) {
    final snackbar = new SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: MyColorScheme.accent()),
      ),
      backgroundColor: MyColorScheme.uno(),
      duration: Duration(seconds: 1),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackbar);
  }

  // building own list of tags, cozz listview builder too much bt
  List<Widget> _buildList(BuildContext context) {
    int i;
    String k;
    // fill in keys if the list is not long enough (in case one key is added)
    i = 0;
    return flashCardData.map<Widget>(
      (FlashCard data) {
        i++;
        k = '${i * flashCardData.length}';
        print(k);
        // if (flashCardData.indexOf(data) == 0) {
        //   return Padding(
        //     key: ValueKey(k),
        //     padding: EdgeInsets.zero,
        //   );
        // } else {
          return Dismissible(
            key: ValueKey(k),
            onDismissed: (direction) {
              setState(() {
                flashCardData.remove(data);
              });
            },
            background: Container(
              color: Colors.red[400],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColorScheme.accent(),
                      ),
                child: !data.isOneSided ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !data.isTermPhoto ? Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextFormField(
                            maxLines: null,
                            textAlign: TextAlign.center,
                            initialValue: data.term,
                            onChanged: (val) {
                              flashCardData[flashCardData.indexOf(data)]
                                  .term = val;
                            },
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                                color: MyColorScheme.uno(), fontSize: 16),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Term',
                              hintStyle:
                                  (TextStyle(color: Colors.white70)),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15,
                                  bottom: 0,
                                  top: 11,
                                  right: 15),
                            )),
                        ): 
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                            padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                            child: Image.network(
                              data.term,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress
                                                .expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              // height: 250,
                              height:
                                  MediaQuery.of(context).size.width * 0.5,
                              width:
                                  MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.image),
                              color: MyColorScheme.uno(),
                              iconSize: 20,
                              onPressed: (){
                                imagePopUp(context, data, true);
                              },
                            ),
                            data.isTermPhoto ? IconButton(
                              icon: Icon(Icons.cancel),
                              color: Colors.white,
                              onPressed: (){
                                setState(() {
                                  flashCardData[flashCardData.indexOf(data)].isTermPhoto = false;
                                  flashCardData[flashCardData.indexOf(data)].term = '';
                                });
                              },
                            ) : Container(height: 0,)
                          ],
                        )
                      ],
                    ),
                    Container(width: MediaQuery.of(context).size.width * 0.6,child: Divider(thickness: 2,color: Colors.white,)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        !data.isDefinitionPhoto ? Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextFormField(
                              maxLines: null,
                              textAlign: TextAlign.center,
                              initialValue: data.definition,
                              style: TextStyle(color: MyColorScheme.uno()),
                              onChanged: (val) {
                                flashCardData[flashCardData.indexOf(data)]
                                    .definition = val;
                              },
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: 'Definition',
                                hintStyle: (TextStyle(color: Colors.white70)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 15, bottom: 11, top: 0, right: 15),
                              ),
                            ),
                        ): 
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                            padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                            child: Image.network(
                              data.definition,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress
                                                .expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              // height: 250,
                              height:
                                  MediaQuery.of(context).size.width * 0.5,
                              width:
                                  MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.image),
                              color: MyColorScheme.uno(),
                              iconSize: 20,
                              onPressed: (){
                                imagePopUp(context, data, false);
                              },
                            ),
                            data.isDefinitionPhoto ? IconButton(
                              icon: Icon(Icons.cancel),
                              color: Colors.white,
                              onPressed: (){
                                setState(() {
                                  flashCardData[flashCardData.indexOf(data)].isDefinitionPhoto = false;
                                  flashCardData[flashCardData.indexOf(data)].definition = '';
                                });
                              },
                            ) : Container(height: 0,)
                          ],
                        )
                      ],
                    ),
                  ],
                ) : 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    !data.isTermPhoto ? Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10) ,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                        maxLines: null,
                        textAlign: TextAlign.center,
                        initialValue: data.term,
                        onChanged: (val) {
                          flashCardData[flashCardData.indexOf(data)]
                              .term = val;
                        },
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                            color: MyColorScheme.uno(), fontSize: 16),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Term',
                          hintStyle:
                              (TextStyle(color: Colors.white24)),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15,
                              bottom: 0,
                              top: 11,
                              right: 15),
                        )),
                    ): 
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                        padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                        child: Image.network(
                          data.term,
                          loadingBuilder: (BuildContext context,
                              Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress
                                            .expectedTotalBytes !=
                                        null
                                    ? loadingProgress
                                            .cumulativeBytesLoaded /
                                        loadingProgress
                                            .expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                          // height: 250,
                          height:
                              MediaQuery.of(context).size.width * 0.5,
                          width:
                              MediaQuery.of(context).size.width * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.image),
                          color: MyColorScheme.uno(),
                          iconSize: 20,
                          onPressed: (){
                            imagePopUp(context, data, true);
                          },
                        ),
                        data.isTermPhoto ? IconButton(
                          icon: Icon(Icons.cancel),
                          color: Colors.white,
                          onPressed: (){
                            setState(() {
                              flashCardData[flashCardData.indexOf(data)].isTermPhoto = false;
                              flashCardData[flashCardData.indexOf(data)].term = '';
                            });
                          },
                        ) : Container(height: 0,)
                      ],
                    )
                  ],
                ),
              ),
            )
            // Stack(
            //   children: <Widget>[
            //     Padding(
            //       key: ValueKey(k),
            //       padding: const EdgeInsets.all(5.0),
            //       child: Container(
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             color: MyColorScheme.accent(),
            //           ),
            //           child: Form(
            //             child: Column(
            //               children: <Widget>[
            //                 Container(
            //                   width: MediaQuery.of(context).size.width * 0.6,
                              // child: TextFormField(
                              //     maxLines: null,
                              //     textAlign: TextAlign.center,
                              //     initialValue: data.term,
                              //     onChanged: (val) {
                              //       flashCardData[flashCardData.indexOf(data)]
                              //           .term = val;
                              //     },
                              //     keyboardType: TextInputType.multiline,
                              //     style: TextStyle(
                              //         color: MyColorScheme.uno(), fontSize: 16),
                              //     decoration: InputDecoration(
                              //       counterText: '',
                              //       hintText: 'Term',
                              //       hintStyle:
                              //           (TextStyle(color: Colors.white24)),
                              //       border: InputBorder.none,
                              //       focusedBorder: InputBorder.none,
                              //       enabledBorder: InputBorder.none,
                              //       errorBorder: InputBorder.none,
                              //       disabledBorder: InputBorder.none,
                              //       contentPadding: EdgeInsets.only(
                              //           left: 15,
                              //           bottom: 0,
                              //           top: 11,
                              //           right: 15),
                              //     )),
            //                 ),
            //                 Padding(
            //                   padding: const EdgeInsets.all(10.0),
            //                   child: Divider(
            //                     color: Colors.grey[800],
            //                     endIndent: 20,
            //                     indent: 20,
            //                   ),
            //                 ),
            //                 if (data.isDefinitionPhoto == false) ...[
                              // TextFormField(
                              //   maxLines: null,
                              //   textAlign: TextAlign.center,
                              //   initialValue: data.definition,
                              //   style: TextStyle(color: MyColorScheme.uno()),
                              //   onChanged: (val) {
                              //     flashCardData[flashCardData.indexOf(data)]
                              //         .definition = val;
                              //   },
                              //   textInputAction: TextInputAction.newline,
                              //   decoration: InputDecoration(
                              //     hintText: 'Definition',
                              //     hintStyle: (TextStyle(color: Colors.white24)),
                              //     border: InputBorder.none,
                              //     focusedBorder: InputBorder.none,
                              //     enabledBorder: InputBorder.none,
                              //     errorBorder: InputBorder.none,
                              //     disabledBorder: InputBorder.none,
                              //     contentPadding: EdgeInsets.only(
                              //         left: 15, bottom: 11, top: 0, right: 15),
                              //   ),
                              // ),
            //                 ] else ...[
            //                   if (data.definition == 'null') ...[
            //                     Container(
            //                       padding: EdgeInsets.all(10),
            //                       child: Row(
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceAround,
            //                         children: <Widget>[
                                      // IconButton(
                                      //   icon: Icon(Icons.camera),
                                      //   color: Colors.white,
                                      //   onPressed: () {
                                      //     getImage(ImageSource.camera, context,
                                      //         flashCardData.indexOf(data));
                                      //   },
                                      // ),
                                      // IconButton(
                                      //   icon: Icon(Icons.photo),
                                      //   color: Colors.white,
                                      //   onPressed: () {
                                      //     getImage(ImageSource.gallery, context,
                                      //         flashCardData.indexOf(data));
                                      //   },
                                      // )
            //                         ],
            //                       ),
            //                     ),
            //                   ] else ...[
                                // Padding(
                                //   padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                //   child: Image.network(
                                //     data.definition,
                                //     loadingBuilder: (BuildContext context,
                                //         Widget child,
                                //         ImageChunkEvent loadingProgress) {
                                //       if (loadingProgress == null) return child;
                                //       return Center(
                                //         child: CircularProgressIndicator(
                                //           value: loadingProgress
                                //                       .expectedTotalBytes !=
                                //                   null
                                //               ? loadingProgress
                                //                       .cumulativeBytesLoaded /
                                //                   loadingProgress
                                //                       .expectedTotalBytes
                                //               : null,
                                //         ),
                                //       );
                                //     },
                                //     // height: 250,
                                //     height:
                                //         MediaQuery.of(context).size.width * 0.5,
                                //     width:
                                //         MediaQuery.of(context).size.width * 0.5,
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
            //                   ]
            //                 ]
            //               ],
            //             ),
            //           )),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(20.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.end,
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: <Widget>[
            //           IconButton(
            //             icon: Icon(Icons.delete_outline),
            //             color: Colors.white,
            //             onPressed: () {
            //               setState(() {
            //                 flashCardData.remove(data);
            //                 print(flashCardData.length);
            //                 fieldCount--;
            //               });
            //             },
            //           ),
            //         ],
            //       ),
            //     )
            //   ],
            // ),
          );
      },
    ).toList(); // building the list of flashcards in their edit mode
  }

  imagePopUp(BuildContext context, FlashCard data, bool forTerm){
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.camera),
                          color: Colors.black,
                          onPressed: () async {
                            Navigator.pop(context);
                            await getImage(ImageSource.camera, context,
                                flashCardData.indexOf(data), forTerm);
                          },
                        ),
                        Text('Camera')
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.photo),
                          color: Colors.black,
                          onPressed: () async{
                            Navigator.pop(context);
                            await getImage(ImageSource.gallery, context,
                                flashCardData.indexOf(data), forTerm);
                          },
                        ),
                        Text('Gallery'),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      textColor: Colors.redAccent,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
  }

  bool _disableTouch = false;
  ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    // generate the list of TextFields
    final List<Widget> children = _buildList(context);
    // append an 'add player' button to the end of the list
    children.add(Container(
      height: MediaQuery.of(context).size.height * 0.3,
    ));
    // build the ListView
    return AbsorbPointer(
      absorbing: _disableTouch,
      child: Column(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Scrollbar(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                children: children,
                key: Key(deck.deckName),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final dynamic item = flashCardData.removeAt(oldIndex);
      flashCardData.insert(newIndex, item);
    });
  }

  @override
  void initState() {
    super.initState();
    print("length recieved ${flashCardData.length}");
    fieldCount = flashCardData.length;
    super.initState();
  }
}
