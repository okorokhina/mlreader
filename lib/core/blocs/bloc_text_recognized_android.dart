import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/ui/select_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class TextRecognizedBloc extends BlocBase{
  File pickedImage;
  List<String> listText;

  final detectedText = BehaviorSubject();
  final photo = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;

  Future pickCamera() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    pickedImage = tempStore;
    photo.add(pickedImage);
    readText();
  }

  Future pickGallery() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);
    pickedImage = tempStore;
    photo.add(pickedImage);
    readText();
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizerText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizerText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
        }
      }
    }
  }

  dispose() {
    detectedText.close();
    photo.close();
  }
}
