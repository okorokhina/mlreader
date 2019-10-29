import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/blocs/bloc_text_recognized.dart';
import 'package:mlreader/core/models/voice.dart';
import 'package:mlreader/core/resourses/tts_api.dart';
import 'package:mlreader/core/ui/widgets/audio_player.dart';
import 'package:mlreader/core/ui/widgets/internet_connection.dart';
import 'package:mlreader/core/ui/widgets/notice.dart';
import 'package:mlreader/core/ui/widgets/scan_button.dart';
import 'package:mlreader/core/ui/widgets/select_button.dart';
import 'package:mlreader/core/ui/widgets/voice_dropdown.dart';

class SelectView extends StatefulWidget {
  SelectView({@required this.textRecognizedBloc});

  final TextRecognizedBloc textRecognizedBloc;

  @override
  State<StatefulWidget> createState() {
    return SelectViewState();
  }
}

class SelectViewState extends State<SelectView> with TickerProviderStateMixin {
  List<Voice> _voices = [];
  Voice _selectedVoice;
  double bottom;

  @override
  void initState() {
    super.initState();
    getVoices();
//    widget.textRecognizedBloc.outVoice.listen((voice) =>
//    _selectedVoice = voice);
  }

  @override
  Widget build(BuildContext context) {
    Device.get().isIphoneX ? bottom = 100 : bottom = 65;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.textRecognizedBloc.audio = null;
              widget.textRecognizedBloc.stop();
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            "ML Reader",
          ),
        ),
        body: Stack(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 55,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                      child: Container(
                    height: 29,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.white)),
                    margin: EdgeInsets.only(left: 8, right: 8),
                       child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ScanButton(
                            textRecognizedBloc: widget.textRecognizedBloc,
                            onTap: () {
                              widget.textRecognizedBloc.audioPlugin.stop();
                              Navigator.of(context).pop();
                              widget.textRecognizedBloc.scanColor
                                  .add(Colors.white);
                              widget.textRecognizedBloc.selectColor.add(null);
                              widget.textRecognizedBloc.audio = null;
                            },
                          ),
                          SelectButton(
                              textRecognizedBloc: widget.textRecognizedBloc,
                              onTap: () {
                                widget.textRecognizedBloc.audioPlugin.stop();
                                widget.textRecognizedBloc.audio = null;
                                widget.textRecognizedBloc.scanColor.add(null);
                                widget.textRecognizedBloc.selectColor
                                    .add(Colors.white);
                                widget.textRecognizedBloc.pickGallery();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectView(
                                            textRecognizedBloc:
                                                widget.textRecognizedBloc)));
                              })
                        ]),
                  ))),
              Expanded(
                  child: Container(
                child: StreamBuilder(
                  stream: widget.textRecognizedBloc.outPhoto,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            image: DecorationImage(
                                image: FileImage(File(snapshot.data)))),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )),

              MLAudioPlayer(
                textRecognizedBloc: widget.textRecognizedBloc,
              ),
//              StreamBuilder<Voice>(
//                stream: widget.textRecognizedBloc.outVoice,
//                builder: (context, voiceSnapshot){
//                  _selectedVoice = voiceSnapshot.data;
                   Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: StreamBuilder<Voice>(
                          stream: widget.textRecognizedBloc.outVoice,
                          builder: (context, voiceSnapshot) {
                            if(voiceSnapshot.hasData){
                              var voices;
                              voices.map((f) => DropdownMenuItem(
                                value: f,
                                child:
                                Text('${voiceSnapshot.data.languageCodes.first} - ${voiceSnapshot.data.gender}'),
                              ));
//                              voiceSnapshot.data(
//                                      (e) =>
//                                  e.name == 'en-US-Wavenet-F' && e.languageCodes.first == 'en-US',
//                                  orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
                              return VoiceDropdown(textRecognizedBloc: widget.textRecognizedBloc, selectedVoice: voiceSnapshot.data, voices: voices);

                            }
                            return VoiceDropdown(textRecognizedBloc: widget.textRecognizedBloc, selectedVoice: _selectedVoice, voices: _voices);
                          }),),
                  ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                child: Container(
                    margin: EdgeInsets.only(bottom: bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/Download.png"),
                        SizedBox(width: 5),
                        Text("Save to file storage")
                      ],
                    )),
                onTap: () {
                  widget.textRecognizedBloc.saveAudio();
                  widget.textRecognizedBloc.noticeOpacity.add(1.0);
                  Timer(Duration(seconds: 1),
                      () => widget.textRecognizedBloc.noticeOpacity.add(0.0));
                },
              )
            ],
          ),
          Positioned(
            child: InternetConnection(
                textRecognizedBloc: widget.textRecognizedBloc),
          ),
          Notice(
              textRecognizedBloc:
                  widget.textRecognizedBloc) // Audio Save Notification
        ]));
  }

  void getVoices() async {
    List<Voice> voices = await TextToSpeechAPI().getVoices();
    if (voices == null) return;
    _selectedVoice = voices.firstWhere(
            (e) =>
        e.name == 'en-US-Wavenet-F' && e.languageCodes.first == 'en-US',
        orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
    widget.textRecognizedBloc.setVoice(_selectedVoice);
    _voices = voices;
  }

//  Voice _fetchVoice(Voice voice){
//    if(voice == null){
//      return _selectedVoice;
//    } else{
//      return voice;
//    }
//  }

}
