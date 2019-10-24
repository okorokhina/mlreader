import 'package:mlreader/core/models/voice.dart';
import 'package:mlreader/core/resourses/tts_api.dart';
import 'package:mlreader/core/resourses/ads_banner.dart';
import 'package:mlreader/core/resourses/network_manager.dart';

class Repository {
  TextToSpeechAPI ttsGoogle = TextToSpeechAPI();
  NetworkManager networkManager = NetworkManager();
  final ads = Ads();

  getVoice(String locale) => ttsGoogle.getVoice(locale);
  saveAudion() => ttsGoogle.saveAudion();
  writeAudioFile(String voiceText, Voice voice) => ttsGoogle.writeAudioFile(voiceText, voice);

  Future adsBanner() => ads.showBanner();

  convert(base64Image) => networkManager.convert(base64Image);
}
