import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:mlreader/core/resourses/repository.dart';

class LanguageBloc{
  Repository res = Repository();

  identifyLanguage(String text) async {
    List<LanguageLabel> lang = await res.identifyLang(text);
    for(var l in lang){
      print("lang " + l.languageCode.toString());
    }
  }
}