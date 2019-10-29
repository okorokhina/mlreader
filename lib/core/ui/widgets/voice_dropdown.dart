import 'package:flutter/material.dart';
import 'package:mlreader/core/models/voice.dart';
import 'package:mlreader/core/resourses/tts_api.dart';

class VoiceDropdown extends StatelessWidget {
  final textRecognizedBloc;
  Voice selectedVoice;
  List<Voice> voices;

  VoiceDropdown({@required this.textRecognizedBloc, this.selectedVoice, this.voices});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DropdownButton(
      value: selectedVoice,
      hint: Text('Select Voice'),
      items: voices
          .map((f) => DropdownMenuItem(
        value: f,
        child:
        Text('${f.languageCodes.first} - ${f.gender}'),
      ))
          .toList(),
      onChanged: (voice) {
        textRecognizedBloc.setVoice(voice);
        textRecognizedBloc.writeAudio(selectedVoice);
      },
    );
  }


}