import 'package:mlreader/core/resourses/ads_banner.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';

class Repository{
  TextToSound tts = TextToSound();
  final ads = Ads();

  getVoice(String voiceText) => tts.speak(voiceText);
  Future adsBanner() => ads.showBanner();
}