import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';



class MyHomePagee extends StatefulWidget {
  static const String id = 'Home';

  @override
  _MyHomePageeState createState() => _MyHomePageeState();
}

class _MyHomePageeState extends State<MyHomePagee> {
  File pickedImage;

  bool isImageLoaded = false;




  RegExp regEx =new RegExp(r"\d{1,3}(?:[,]\d{2,3})*(?:[.]\d{2})");

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
    readText();
  }

  Future readText() async {
    List<String> receipt_desc= new List();
    List<double> receipt_amt= new List();
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          String desc="";
          double amount=0.0;
          int onoff = 0;
          line.elements.forEach((element) {
            if(regEx.hasMatch(element.text)){
              onoff = 1;
             amount = double.tryParse(regEx.stringMatch(element.text)).toDouble();
            }
          else if(onoff == 0)
            desc=desc+element.text;
          });

          receipt_desc.add(desc.trim().isEmpty ? "Undefined" : desc);
          receipt_amt.add(amount);
        }
      }
    }
    print(receipt_amt);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            isImageLoaded
                ? Center(
              child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(pickedImage), fit: BoxFit.cover))),
            )
                : Container(),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Pick an image'),
              onPressed: pickImage,
            ),
            SizedBox(height: 10.0),
            RaisedButton(
              child: Text('Read Text'),
              onPressed: readText,
            ),

          ],
        ));
  }
}