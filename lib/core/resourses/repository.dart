import 'package:imagetospeech/core/models/voice.dart';
import 'package:imagetospeech/core/resourses/file_picker.dart';
import 'package:imagetospeech/core/resourses/tts_api.dart';
import 'package:imagetospeech/core/resourses/ads_banner.dart';
import 'package:imagetospeech/core/resourses/network_manager.dart';

class Repository {
  TextToSpeechAPI ttsGoogle = TextToSpeechAPI();
  NetworkManager networkManager = NetworkManager();
  final ads = Ads();
  final _picker = Picker();

  getAudio() => _picker.openFileExplorer();
  getVoice(String locale) => ttsGoogle.getVoice(locale);
  saveAudio() => ttsGoogle.saveAudio();
  writeAudioFile(String voiceText, Voice voice) => ttsGoogle.writeAudioFile(voiceText, voice);

  Future adsBanner() => ads.showBanner();

  convert(base64Image) => networkManager.convert(base64Image);
}
