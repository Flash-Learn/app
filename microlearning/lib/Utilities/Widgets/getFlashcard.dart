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
  getImage(ImageSource source, BuildContext context, int index) async {
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
          flashCardData[index].definition =
              url; // saving the url into the list of flashcards
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
        k = '$i';
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
                fieldCount--;
              });
            },
            background: Container(
              color: Colors.grey,
            ),
            child: Stack(
              children: <Widget>[
                Padding(
                  key: ValueKey(k),
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColorScheme.accent(),
                      ),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Divider(
                                color: Colors.grey[800],
                                endIndent: 20,
                                indent: 20,
                              ),
                            ),
                            if (data.isDefinitionPhoto == false) ...[
                              TextFormField(
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
                                  hintStyle: (TextStyle(color: Colors.white24)),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 0, right: 15),
                                ),
                              ),
                            ] else ...[
                              if (data.definition == 'null') ...[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.camera),
                                        color: Colors.white,
                                        onPressed: () {
                                          getImage(ImageSource.camera, context,
                                              flashCardData.indexOf(data));
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.photo),
                                        color: Colors.white,
                                        onPressed: () {
                                          getImage(ImageSource.gallery, context,
                                              flashCardData.indexOf(data));
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
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
                              ]
                            ]
                          ],
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            flashCardData.remove(data);
                            print(flashCardData.length);
                            fieldCount--;
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
      },
    ).toList(); // building the list of flashcards in their edit mode
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red[300],
                  child: MaterialButton(
                    //color: Colors.blue,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.text_fields,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          "Add text card",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        fieldCount++;
                        flashCardData.add(FlashCard(term: '', definition: '', isTermPhoto: false, isDefinitionPhoto: false, isOneSided: false));
                        //TODO: generate a id for flash card....But I don't think we will need this
                      });
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    },
                  ),
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red[300],
                  child: MaterialButton(
                    key: ValueKey('photo card'),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          "Add photo card",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        fieldCount++;
                        try {
                          flashCardData.add(FlashCard(term: '', definition: 'null', isTermPhoto: false, isDefinitionPhoto: true, isOneSided: false));
                        } catch (e) {
                          print('here is the error');
                          print(e);
                        }
                        //TODO: generate a id for flash card....But I don't think we will need this
                      });
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
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
