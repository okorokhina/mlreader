import 'package:mlreader/core/resourses/ads_banner.dart';
import 'package:mlreader/core/resourses/network_manager.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';

class Repository {
  TextToSound tts = TextToSound();
  NetworkManager networkManager = NetworkManager();
  final ads = Ads();

  getVoice(String voiceText, String lang) => tts.speak(voiceText, lang);
  Future adsBanner() => ads.showBanner();

  stop(tap) => tts.stop(tap);

  convert(base64Image) => networkManager.convert(base64Image);
}
