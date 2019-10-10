import 'dart:io';
import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/resourses/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

class TextRecognizedBloc extends BlocBase {
  Repository rep = Repository();
  final detectedText = BehaviorSubject();
  final photo = BehaviorSubject();
  final scanColor = BehaviorSubject();
  final selectColor = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;
  Observable get outScanColor => scanColor.stream;
  Observable get outSelectColor => selectColor.stream;

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> takePhoto(BuildContext context, _controller) async {
    if (!_controller.value.isInitialized) {
      return null;
    }
    final Directory textDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${textDir.path}/Pictures/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_getTimestamp()}.jpg';

    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      await _controller.takePicture(filePath);
      File image = await FlutterExifRotation.rotateImage(path: filePath);
      photo.add(filePath);
      readText(File(image.path));
    } catch (e) {
      print(e);
    }
  }

  Future pickGallery() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);
    scanColor.add(null);
    selectColor.add(Colors.white);
    if (tempStore != null) {
      File image = await FlutterExifRotation.rotateImage(path: tempStore.path);
      photo.add(tempStore.path);
      readText(image);
    }
  }

  identifyLanguage(String text) async {
    List<LanguageLabel> lang = await rep.identifyLang(text);
    String language = '';
    for(var l in lang){
      print("lang " + l.languageCode.toString());
      language = l.languageCode.toString();
    }

    getVoice(text, language);
    return language;
  }
  getVoice(String voiceText, lang){
    rep.getVoice(voiceText, lang);
  }

  Future readText(File filePath) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(filePath);
    TextRecognizer recognizerText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizerText.processImage(ourImage);
    StringBuffer buffer = StringBuffer();

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
          final List<RecognizedLanguage> languages = block.recognizedLanguages;
          buffer.write(word.text);

//          print("languages languages languages====> $languages");
//          for(var l in block.recognizedLanguages){
//            print("lang code --------------->"+l.languageCode.toString());
//          }
        }
      }
    }
    identifyLanguage(buffer.toString());


  }

  dispose() {
    detectedText.close();
    photo.close();
    scanColor.close();
    selectColor.close();
  }
}
