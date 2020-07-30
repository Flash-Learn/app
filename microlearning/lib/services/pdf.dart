//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:microlearning/Models/deck.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

generatePDF(String deckID) async {
  print("----------------------------------------------------------");
  print("generating");
  print("----------------------------------------------------------");
  Deck deck = Deck(deckID: deckID);
  final pdfLib.Document pdf = pdfLib.Document();
  final deckRef =
      await Firestore.instance.collection("decks").document(deckID).get();
  deck.deckName = deckRef.data["deckName"];
  deck.flashCardList = deckRef.data["flashcardList"];

  var tempCard =
      List.generate(deck.flashCardList.length, (i) => List(5), growable: false);
  for (var i = 0; i < deck.flashCardList.length; i++) {
    final ds = await Firestore.instance
        .collection('flashcards')
        .document(deck.flashCardList[i])
        .get();
    tempCard[i][0] = ds.data["isTermPhoto"];
    tempCard[i][2] = ds.data["isDefinitionPhoto"];
    tempCard[i][4] = ds.data["isOneSided"];

    if (tempCard[i][0] == true) {
      tempCard[i][1] = await pdfImageFromImageProvider(
        pdf: pdf.document,
        image: NetworkImage(
          ds.data["term"],
        ),
      );
    } else {
      tempCard[i][1] = ds.data["term"];
    }

    if (tempCard[i][2] == true) {
      tempCard[i][3] = await pdfImageFromImageProvider(
        pdf: pdf.document,
        image: NetworkImage(
          ds.data["definition"],
        ),
      );
    } else {
      tempCard[i][3] = ds.data["definition"];
    }
  }

  pdf.addPage(pdfLib.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pdfLib.EdgeInsets.all(32),
      build: (context) {
        return <pdfLib.Widget>[
          pdfLib.Header(
              level: 0,
              child: pdfLib.Text(deck.deckName,
                  style: pdfLib.TextStyle(fontSize: 26))),
          pdfLib.Column(
            children: List.generate(deck.flashCardList.length, (index) {
              return pdfLib.Column(children: <pdfLib.Widget>[
                if (tempCard[index][0] == false) ...[
                  pdfLib.Paragraph(
                      text: "${index + 1}.  ${tempCard[index][1]}",
                      style: pdfLib.TextStyle(
                          fontSize: 20, fontWeight: pdfLib.FontWeight.bold)),
                ] else ...[
                  pdfLib.Paragraph(
                      text: "${index + 1}.",
                      style: pdfLib.TextStyle(fontSize: 22)),
                  pdfLib.Image(tempCard[index][1]),
                  pdfLib.SizedBox(height: 20),
                ],
                if (tempCard[index][2] == false) ...[
                  pdfLib.Paragraph(
                      margin: pdfLib.EdgeInsets.only(left: 10),
                      text: "${tempCard[index][3]} ",
                      style: pdfLib.TextStyle(fontSize: 18)),
                  pdfLib.SizedBox(height: 10)
                ] else ...[
                  pdfLib.Image(tempCard[index][3]),
                  pdfLib.SizedBox(height: 20)
                ],
              ]);
            }),
          )
        ];
      }));

  // final String dir = (await getApplicationDocumentsDirectory()).path;
  // print(dir);
  // final String path = '$dir/test_pdf.pdf';
  // final File file = File(path);
  // await file.writeAsBytes(pdf.save());
  Printing.sharePdf(bytes: pdf.save(), filename: '${deck.deckName}.pdf');
}
