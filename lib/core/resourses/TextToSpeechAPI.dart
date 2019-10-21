import 'dart:io';
import 'dart:async';
import 'dart:convert' show Base64Decoder, json, utf8;

import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

class TextToSpeechAPI {

  static final TextToSpeechAPI _singleton = TextToSpeechAPI._internal();
  final _httpClient = HttpClient();
  static const _apiKey = "AIzaSyDO0ew9TxAXw1fTzfYioUuP-IYLj2iiqcA";
  static const _apiURL = "texttospeech.googleapis.com";
  AudioPlayer audioPlugin = AudioPlayer();


  factory TextToSpeechAPI() {
    return _singleton;
  }

  TextToSpeechAPI._internal();

  void writeAudioFile(String text, String locale) async {
    if (audioPlugin.state == AudioPlayerState.PLAYING) {
      await audioPlugin.stop();
    }
    print("locale  $locale");
//    final String audioContent = await TextToSpeechAPI().synthesizeText(text, _selectedVoice.name, _selectedVoice.languageCodes.first);
    final String audioContent = await TextToSpeechAPI().synthesizeText(text,'en-US-Wavenet-F', locale);
    if (audioContent == null) return;
    final bytes = Base64Decoder().convert(audioContent, 0, audioContent.length);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wavenet.mp3');
    await file.writeAsBytes(bytes);
    await audioPlugin.play(file.path, isLocal: true);
  }

  Future<dynamic> synthesizeText(String text, String name, String languageCode) async {
    try {
      final uri = Uri.https(_apiURL, '/v1beta1/text:synthesize');
      final Map json = {
        'input': {
          'text': text
        },
        'voice': {
          'name': name,
          'languageCode': languageCode
        },
        'audioConfig': {
          'audioEncoding': 'MP3'
        }
      };

      final jsonResponse = await _postJson(uri, json);
      if (jsonResponse == null) return null;
      final String audioContent = await jsonResponse['audioContent'];
      return audioContent;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<List<Voice>> getVoices() async {
    try {
      final uri = Uri.https(_apiURL, '/v1beta1/voices');

      final jsonResponse = await _getJson(uri);
      if (jsonResponse == null) {
        return null;
      }

      final List<dynamic> voicesJSON = jsonResponse['voices'].toList();

      if (voicesJSON == null) {
        return null;
      }

      final voices = Voice.mapJSONStringToList(voicesJSON);
      return voices;
    } on Exception catch(e) {
      print("$e");
      return null;
    }

  }

  Future<Map<String, dynamic>> _postJson(Uri uri, Map jsonMap) async {
    try {
      final httpRequest = await _httpClient.postUrl(uri);
      final jsonData = utf8.encode(json.encode(jsonMap));
      final jsonResponse = await _processRequestIntoJsonResponse(httpRequest, jsonData);
      return jsonResponse;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final jsonResponse = await _processRequestIntoJsonResponse(httpRequest, null);
      return jsonResponse;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _processRequestIntoJsonResponse(HttpClientRequest httpRequest, List<int> data) async {
    try {
      httpRequest.headers.add('X-Goog-Api-Key', _apiKey);
      httpRequest.headers.add(HttpHeaders.CONTENT_TYPE, 'application/json');
      if (data != null) {
        httpRequest.add(data);
      }
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        throw Exception('Bad Response');
      }
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }
}

class Voice {
  final String name;
  final String gender;
  final List<String> languageCodes;

  Voice(this.name, this.gender, this.languageCodes);

  static List<Voice> mapJSONStringToList(List<dynamic> jsonList) {
    return jsonList.map((v) {
      return Voice(v['name'], v['ssmlGender'], List<String>.from(v['languageCodes']));
    }).toList();
  }
}