import 'package:mlreader/core/resourses/TextToSpeechAPI.dart';
import 'package:mlreader/core/resourses/ads_banner.dart';
import 'package:mlreader/core/resourses/network_manager.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';

class Repository {
  TextToSound tts = TextToSound();
  TextToSpeechAPI ttsGoogle = TextToSpeechAPI();
  NetworkManager networkManager = NetworkManager();
  final ads = Ads();

//  getVoice(String voiceText, String lang) => tts.speak(voiceText, lang);
  getVoice() => ttsGoogle.getVoices();
  writeAudioFile(String voiceText, String locale) => ttsGoogle.writeAudioFile(voiceText, locale);
  Future adsBanner() => ads.showBanner();

  stop(tap) => tts.stop(tap);
  saveAudion() => ttsGoogle.saveAudion();
  // playAudio() => ttsGoogle.play();
  // pauseAudio() => ttsGoogle.pause();

  convert(base64Image) => networkManager.convert(base64Image);
}
