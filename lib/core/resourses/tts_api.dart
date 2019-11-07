import 'dart:io';
import 'dart:async';
import 'dart:convert' show Base64Decoder, json, utf8;

import 'package:imagetospeech/core/models/voice.dart';
import 'package:path_provider/path_provider.dart';

class TextToSpeechAPI {
  static final TextToSpeechAPI _singleton = TextToSpeechAPI._internal();
  final _httpClient = HttpClient();
  static const _apiKey = "AIzaSyDO0ew9TxAXw1fTzfYioUuP-IYLj2iiqcA";
  static const _apiURL = "texttospeech.googleapis.com";
  static const _speakingRate = 0.8;
  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  var bytes;
  factory TextToSpeechAPI() {
    return _singleton;
  }

  TextToSpeechAPI._internal();

  writeAudioFile(String text, Voice voice) async {
    final String audioContent = await TextToSpeechAPI()
        .synthesizeText(text, voice.name, voice.languageCodes.first);
    bytes = Base64Decoder().convert(audioContent, 0, audioContent.length);
    final dir = await getTemporaryDirectory();
    final audioFile = File('${dir.path}/${_getTimestamp()}.mp3');
    await audioFile.writeAsBytes(bytes);
    return audioFile.path;
  }

  // Create a path audio for iOS and Android platforms and save audio file
  saveAudio() async {
    String dirPath;
    if (Platform.isAndroid) {
      Directory androidTextDir = await getExternalStorageDirectory();
      dirPath = "${androidTextDir.path}/AudioText";
    } else {
      Directory iOStextDir = await getApplicationDocumentsDirectory();
      dirPath = "${iOStextDir.path}/AudioText";
    }
    await Directory(dirPath).create(recursive: true);
    final filePath = File('$dirPath/${_getTimestamp()}.mp3');
    await filePath.writeAsBytes(bytes);
  }

  Future<dynamic> synthesizeText(
      String text, String name, String languageCode) async {
    try {
      final uri = Uri.https(_apiURL, '/v1beta1/text:synthesize');
      final Map json = {
        'input': {'text': text},
        'voice': {'name': name, 'languageCode': languageCode},
        'audioConfig': {'audioEncoding': 'MP3', "speakingRate": _speakingRate}
      };
      final jsonResponse = await _postJson(uri, json);
      if (jsonResponse == null) return null;
      final String audioContent = await jsonResponse['audioContent'];
      return audioContent;
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }

  Future<Voice> getVoice(String locale) async {
    final voices = await getVoices();
    if (voices == null) return null;
    return voices.firstWhere(
        (e) =>
            e.name.contains(locale) && e.languageCodes.first.contains(locale),
        orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
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
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _postJson(Uri uri, Map jsonMap) async {
    try {
      final httpRequest = await _httpClient.postUrl(uri);
      final jsonData = utf8.encode(json.encode(jsonMap));
      final jsonResponse =
          await _processRequestIntoJsonResponse(httpRequest, jsonData);
      return jsonResponse;
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final jsonResponse =
          await _processRequestIntoJsonResponse(httpRequest, null);
      return jsonResponse;
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _processRequestIntoJsonResponse(
      HttpClientRequest httpRequest, List<int> data) async {
    try {
      httpRequest.headers.add('X-Goog-Api-Key', _apiKey);
      httpRequest.headers.add(HttpHeaders.CONTENT_TYPE, 'application/json');
      if (data != null) {
        httpRequest.add(data);
      }
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        print("httpResponse.statusCode " + httpResponse.statusCode.toString());
        throw Exception('Bad Response');
      }
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      print("responseBody " + responseBody.toString());

      return json.decode(responseBody);
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }
}
