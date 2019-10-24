import 'dart:convert';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/models/text_recognize.dart';
import 'package:mlreader/core/models/voice.dart';
import 'package:mlreader/core/resourses/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

class TextRecognizedBloc extends BlocBase {
  Repository rep = Repository();
  AudioPlayer audioPlugin = AudioPlayer();
  var audio;

  final detectedText = BehaviorSubject();
  final photo = BehaviorSubject();
  final scanColor = BehaviorSubject();
  final selectColor = BehaviorSubject();
  final internetConnect = BehaviorSubject();
  final notisOpacity = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;
  Observable get outScanColor => scanColor.stream;
  Observable get outSelectColor => selectColor.stream;
  Observable get outInternetConnect => internetConnect.stream;
  Observable get outNotisOpacity => notisOpacity.stream;

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  StringBuffer buffer = StringBuffer();

  saveAudio() => rep.saveAudion();

  /* Create path in system for photo, rotate the photo if it is not in the correct position,
     add the photo to the stream to select_view screen,
     convert the picture to list of bytes and convert to base64, and send image 
     to Google vision then we get response. */

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
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      TextRecognize text = await rep.convert(base64Image);
      getVoice(text);
    } catch (e) {
      print(e);
    }
  }

  /* Select an image from the gallery, change color in scan and select buttons,
     rotate the picture if it is not in the correct position,
     add the image to the stream to select_view screen,
     convert the picture to list of bytes and convert to base64, and send image 
     to Google vision then we get response. */

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
    buffer.clear();
    for (var response in text.responses) {
      for (var textAnnotation in response.textAnnotations) {
        buffer.write(textAnnotation.description);
        if (textAnnotation.locale != null) {
          var locale = textAnnotation.locale;
          Voice voice = await rep.getVoice(locale);
          writeAudio(voice);
        }
      }
    }
    print("descript " + buffer.toString());
  }

  writeAudio(voice) async {
    if(buffer != null)
      audio = await rep.writeAudioFile(buffer.toString(), voice);
    audioPlugin.play(audio, isLocal: true);
  }

  Future<void> play() async {
    await audioPlugin.play(audio, isLocal: true);
  }

  Future<void> pause() async {
    await audioPlugin.pause();
  }

  rewind(double position, double duration) async {
    double _percentBack = position - (15 / duration);
    await audioPlugin.seek(_percentBack);
  }

  fastForward(double position, double duration) async {
    double percentForward = position + (30 / duration);
    await audioPlugin.seek(percentForward);
  }

  dispose() {
    detectedText.close();
    photo.close();
    scanColor.close();
    selectColor.close();
    internetConnect.close();
    notisOpacity.close();
  }
}
