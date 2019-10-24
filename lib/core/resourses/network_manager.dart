import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import 'package:mlreader/core/models/text_recognize.dart';

class NetworkManager {
  static const _apiKey = "key";
  String url = "https://vision.googleapis.com/v1/images:annotate?key=$_apiKey";

  /* Submit Json to Google vision, get a response and parse Json 
     for the Text Recognize model. */

  Future<TextRecognize> convert(base64Image) async {
    var body = json.encode({
      "requests": [
        {
          "image": {"content": base64Image},
          "features": [
            {"type": "TEXT_DETECTION"}
          ]
        }
      ]
    });

    final response = await http.post(url, body: body);
    var jsonResponse = json.decode(response.body);
    print(response.statusCode);
    print(response.body);
    return TextRecognize.fromJson(jsonResponse);
  }
}
