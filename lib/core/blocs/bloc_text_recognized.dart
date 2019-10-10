import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

class TextRecognizedBloc extends BlocBase {
  final detectedText = BehaviorSubject();
  final photo = BehaviorSubject();
  final scanColor = BehaviorSubject();
  final selectColor = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;
  Observable get outScanColor => scanColor.stream;
  Observable get outSelectColor => selectColor.stream;

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> takePhoto(BuildContext context, controller) async {
    print("dsasffsmfsmfdomfodfmdomfdofmdofmdofm");
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
      readText(File(image.path));
      print(image.path);
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

  Future readText(File filePath) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(filePath);
    TextRecognizer recognizerText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizerText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
          // final List<RecognizedLanguage> languages = block.recognizedLanguages;
        }
      }
    }
  }

  dispose() {
    detectedText.close();
    photo.close();
    scanColor.close();
    selectColor.close();
  }
}
