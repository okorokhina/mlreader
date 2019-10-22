import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/models/text_recognize.dart';
import 'package:mlreader/core/resourses/TextToSpeechAPI.dart';
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
  final internetConnect = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;
  Observable get outScanColor => scanColor.stream;
  Observable get outSelectColor => selectColor.stream;
  Observable get outInternetConnect => internetConnect.stream;

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> takePhoto(BuildContext context, controller) async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory textDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${textDir.path}/Pictures/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_getTimestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }
    try {
      await controller.takePicture(filePath);
      File image = await FlutterExifRotation.rotateImage(path: filePath);
      photo.add(image.path);
      // readText(File(image.path));
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      TextRecognize text = await rep.convert(base64Image);
      getVoice(text);
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
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      TextRecognize text = await rep.convert(base64Image);
      getVoice(text);
    }
  }

  getVoice(TextRecognize text) async {
    StringBuffer buffer = StringBuffer();
    String locale = "";
    for (var response in text.responses) {
      for (var textAnnotation in response.textAnnotations) {
        buffer.write(textAnnotation.description);
        if(textAnnotation.locale != null )  {
          var locale1 = textAnnotation.locale;
          locale =
          "${textAnnotation.locale}-${textAnnotation.locale.toUpperCase()}";
          print("textAnnotation.locale " + locale);
          rep.writeAudioFile(buffer.toString(), locale1);
        }
      }
    }
    print("descript " + buffer.toString());
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
          buffer.write(word.text);
        }
      }
    }
    print("bufer " + buffer.toString());
  }

  top(String tap) => rep.stop(tap);

  dispose() {
    detectedText.close();
    photo.close();
    scanColor.close();
    selectColor.close();
    internetConnect.close();
  }
}
