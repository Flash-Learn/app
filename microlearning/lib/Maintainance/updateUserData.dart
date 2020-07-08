import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  print("1");
  WidgetsFlutterBinding.ensureInitialized();
  String err;
  CollectionReference userCollection =
      Firestore.instance.collection('user_data');
  print("2");
  try {
    await userCollection.getDocuments().then((ds) {
      if (ds != null) {
        ds.documents.forEach((element) async {
          if (element.data["groups"] == null) {
            print(element.data["name"]);
            try {
              await userCollection.document(element.documentID).updateData({
                "groups": [],
              });
            } catch (e) {
              err += e + "\n";
            }
          }
        });
      }
    });
    print("3");
  } catch (e) {
    err += e + "\n";
  }
  print("4");

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
        body: Center(child: Text("Erros: " + err)),
      ),
    );
  }
}
