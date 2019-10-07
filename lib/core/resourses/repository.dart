import 'package:mlreader/core/resourses/text_to_sound.dart';

class Repository{
  TextToSound tts = TextToSound();

  getVoice(String voiceText) => tts.speak(voiceText);
}