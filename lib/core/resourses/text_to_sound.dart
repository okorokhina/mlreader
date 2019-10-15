import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';

class TextToSound{

  final sppek = BehaviorSubject<String>();
   var result;

  Observable<String> get outSppek => sppek.stream;

  FlutterTts flutterTts = FlutterTts();
  dynamic languages;
  dynamic voices;

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
  }

  Future speak(String voiceText, String lang) async {
    // var result;
    await flutterTts.setLanguage(lang);
    if (voiceText != null) {
      if (voiceText.isNotEmpty) {
        // outSppek.listen((data) async{
        //   if(data == null){
            result = await flutterTts.speak(voiceText);
        //   }
        // });
        
      }
    }
    return result;
  }

  Future stop(tap) async{
   await flutterTts.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
}

  dispose(){
    sppek.close();
  }

}