import 'package:mlreader/core/resourses/mlkit_language.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';

class Repository{
  TextToSound tts = TextToSound();
  MlKitLanguage mlkitLang = MlKitLanguage();

  getVoice(String voiceText, String lang) => tts.speak(voiceText, lang);
  identifyLang(String text) => mlkitLang.identifyLanguage(text);
}