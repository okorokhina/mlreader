import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';

class MlKitLanguage{

  Future<dynamic>identifyLanguage(String text) async {
    List<LanguageLabel> result = await FirebaseLanguage.instance.languageIdentifier().processText(text);
    return result;
  }

}