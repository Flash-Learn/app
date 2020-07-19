import 'package:microlearning/Models/deck.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

generatePDF(String deckID) async {
  Deck deck = Deck(deckID: deckID);
  final deckRef =
      await Firestore.instance.collection("decks").document(deckID).get();
  deck.deckName = deckRef.data["deckName"];
  deck.flashCardList = deckRef.data["flashcardList"];

  var tempCard =
      List.generate(deck.flashCardList.length, (i) => List(3), growable: false);
  for (var i = 0; i < deck.flashCardList.length; i++) {
    final ds = await Firestore.instance
        .collection('flashcards')
        .document(deck.flashCardList[i])
        .get();
    tempCard[i][0] = ds.data["term"];
    tempCard[i][1] = ds.data["definition"];
    tempCard[i][2] = ds.data["isimage"];
  }

  final pdfLib.Document pdf = pdfLib.Document();
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
            children: List.generate(
                deck.flashCardList.length,
                (index) => pdfLib.Column(children: <pdfLib.Widget>[
                      pdfLib.Paragraph(
                          text: "${index + 1}. ${tempCard[index][0]}",
                          style: pdfLib.TextStyle(fontSize: 22)),
                      pdfLib.Paragraph(
                          text: "${tempCard[index][1]}",
                          style: pdfLib.TextStyle(fontSize: 18)),
                      pdfLib.SizedBox(height: 10)
                    ])),
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
