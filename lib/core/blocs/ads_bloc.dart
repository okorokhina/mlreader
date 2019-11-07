
import 'package:imagetospeech/core/resourses/repository.dart';

class AdsBloc{

  final _repository = Repository();

Future adsBanner() => _repository.adsBanner();

}