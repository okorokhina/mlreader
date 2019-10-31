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

class TextRecognizedBloc extends BlocBase {
  Repository rep = Repository();
  AudioPlayer audioPlugin = AudioPlayer();
  String audio;

  final detectedText = BehaviorSubject();
  final photo = BehaviorSubject();
  final scanColor = BehaviorSubject();
  final selectColor = BehaviorSubject();
  final internetConnect = BehaviorSubject();
  final noticeOpacity = BehaviorSubject();

  Observable get outDetectedText => detectedText.stream;
  Observable get outPhoto => photo.stream;
  Observable get outScanColor => scanColor.stream;
  Observable get outSelectColor => selectColor.stream;
  Observable get outInternetConnect => internetConnect.stream;
  Observable get outNotisOpacity => noticeOpacity.stream;

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  StringBuffer buffer = StringBuffer();

  saveAudio() => rep.saveAudion();

  // Create path in system for photo

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
    await controller.takePicture(filePath);
    recognizePhoto(filePath);
  }

  // Select an image from the gallery, change color in scan and select buttons

  Future pickGallery() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);
    scanColor.add(null);
    selectColor.add(Colors.white);
    recognizePhoto(tempStore.path);
  }

  /* Rotate the image if it is not in the correct position,
     add the image to the stream to select_view screen,
     convert the image to list of bytes and convert to base64, and send
     to Google vision, then we get respons.*/

  recognizePhoto(filePath) async {
    try {
      File image = File(filePath);
      photo.add(image.path);
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      TextRecognize text = await rep.convert(base64Image);
      getVoice(text);
    } catch (e) {
      print(e);
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
  }

  getAudioPackage() async {
    audio = "audio";
    await audioPlugin.play( await rep.getAudio(), isLocal: true);

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

  Future<void> stop() async {
    await audioPlugin.stop();
  }

  Future<void> rewind(double position) async {
    double _percentBack = position - 1;
    await audioPlugin.seek(_percentBack);
  }

  Future<void> fastForward(double position) async {
    double percentForward = position + 2;
    await audioPlugin.seek(percentForward);
  }

  Future<void> audioPosition(double position) async {
    await audioPlugin.seek(position / 1000);
  }

  dispose() {
    detectedText.close();
    photo.close();
    scanColor.close();
    selectColor.close();
    internetConnect.close();
    noticeOpacity.close();
  }
}
