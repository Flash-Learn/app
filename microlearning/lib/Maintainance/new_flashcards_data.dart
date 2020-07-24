import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STORE ERRORS THAT YOU MIGHT WANT TO DISPLAY IN THE APP HERE
  String err="";

  // MAINTAINANCE CODE GOES HERE

  CollectionReference flashCollection =
  Firestore.instance.collection('flashcards');
  print("2");
  try {
    await flashCollection.getDocuments().then((ds) {
      if (ds != null) {
        ds.documents.forEach((element) async {
          if(true){
            flashCollection.document(element.documentID).updateData({
              'isTermPhoto': false,
              'isDefinitionPhoto': element.data['isimage'] == 'true' ? true : false,
              'isOneSided': false,
            });
          }
          err += element.data["term"];
          print(element.documentID);
        });
      }
    });
    print("3");
  } catch (e) {
    err += e + "\n";
  }
  print("4");

  // PASSING THE ERROR INTO THE APP
  return runApp(MyApp(err: err));
}

class MyApp extends StatelessWidget {
  final String err;
  MyApp({this.err});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Maintainance"),
        ),
        body: Center(child:
          SingleChildScrollView(child: Text("Erros"))
        ),
      ),
    );
  }
}
