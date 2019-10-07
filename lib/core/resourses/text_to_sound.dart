import 'package:flutter_tts/flutter_tts.dart';

class TextToSound{
  FlutterTts flutterTts = FlutterTts();
  dynamic languages;
  dynamic voices;

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
  }

  Future speak(String voiceText) async {
    var result;
    if (voiceText != null) {
      if (voiceText.isNotEmpty) {
        result = await flutterTts.speak(voiceText);
      }
    }
    return result;
  }
}