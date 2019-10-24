import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/models/voice.dart';
import 'package:mlreader/core/resourses/tts_api.dart';
import 'package:mlreader/core/ui/widgets/internet_connection.dart';
import 'package:mlreader/core/ui/widgets/scan_button.dart';
import 'package:mlreader/core/ui/widgets/select_button.dart';
import 'package:audioplayer/audioplayer.dart';

class SelectView extends StatefulWidget {
  SelectView({@required this.textRecognizedBloc});

  final textRecognizedBloc;

  @override
  State<StatefulWidget> createState() {
    return SelectViewState();
  }
}

class SelectViewState extends State<SelectView> with TickerProviderStateMixin {
  double bottom;
  bool play = false;
  AnimationController playPauseController;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  List<Voice> _voices = [];
  Voice _selectedVoice;
  Duration duration;
  Duration position;

  @override
  void initState() {
    super.initState();
    getVoices();
    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _positionSubscription = widget
        .textRecognizedBloc.audioPlugin.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        widget.textRecognizedBloc.audioPlugin.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() {
          duration = widget.textRecognizedBloc.audioPlugin.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          position = duration;
        });
      } else if (s == AudioPlayerState.COMPLETED) {
        playPauseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Device.get().isIphoneX ? bottom = 100 : bottom = 65;
    return Scaffold(
        appBar: AppBar(
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: DropdownButton<Voice>(
                  value: _selectedVoice,
                  hint: Text('Select Voice'),
                  items: _voices
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(
                                '${f.name} - ${f.languageCodes.first} - ${f.gender}'),
                          ))
                      .toList(),
                  onChanged: (voice) {
                    setState(() {
                      _selectedVoice = voice;
                    });
                    widget.textRecognizedBloc.writeAudio(_selectedVoice);
                  },
                ),
              ),
              widget.textRecognizedBloc.audio != null
                  ? Container(
                      margin: EdgeInsets.only(left: 40, right: 40),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.5))),
                            margin: EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                IconButton(
                                  icon: Image.asset("assets/RewindBack.png"),
                                  onPressed: () {
                                    widget.textRecognizedBloc.rewind(
                                        position?.inSeconds?.toDouble(),
                                        duration.inSeconds.toDouble());
                                  },
                                ),
                                InkWell(
                                    onTap: () {
                                      readText();
                                    },
                                    child: Material(
                                        child: AnimatedIcon(
                                      size: 30,
                                      color: Theme.of(context).primaryColor,
                                      icon: AnimatedIcons.pause_play,
                                      progress: playPauseController,
                                    ))),
                                IconButton(
                                  icon: Image.asset("assets/Rewind.png"),
                                  onPressed: () {
                                    widget.textRecognizedBloc.fastForward(
                                        position?.inSeconds?.toDouble(),
                                        duration.inSeconds.toDouble());
                                  },
                                )
                              ],
                            ),
                          ),
                          Center(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Slider(
                                activeColor: Theme.of(context).primaryColor,
                                inactiveColor: Colors.black,
                                value: duration != null
                                    ? position?.inMilliseconds?.toDouble() ??
                                        0.0
                                    : 0.0,
                                onChanged: (double value) => widget
                                    .textRecognizedBloc.audioPlayer
                                    .seek((value / 1000).roundToDouble()),
                                min: 0.0,
                                max: duration != null
                                    ? duration.inMilliseconds.toDouble()
                                    : 0.0),
                          )),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
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
                  widget.textRecognizedBloc.notisOpacity.add(1.0);
                  Timer(Duration(seconds: 1),
                      () => widget.textRecognizedBloc.notisOpacity.add(0.0));
                },
              )
            ],
          ),
          Positioned(
            child: InternetConnection(
                textRecognizedBloc: widget.textRecognizedBloc),
          ),
          notisSaved()
        ]));
  }

  void getVoices() async {
    final voices = await TextToSpeechAPI().getVoices();
    if (voices == null) return;
    setState(() {
      _selectedVoice = voices.firstWhere(
          (e) =>
              e.name == 'en-US-Wavenet-F' && e.languageCodes.first == 'en-US',
          orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
      _voices = voices;
    });
  }

  notisSaved() {
    return StreamBuilder(
      stream: widget.textRecognizedBloc.outNotisOpacity,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return AnimatedOpacity(
              opacity: snapshot.data,
              duration: Duration(seconds: 1),
              child: TickerMode(
                  enabled: false,
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        width: 150,
                        height: 50,
                        child: Center(
                            child: Text(
                          "Audio saved",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ))),
                  )));
        } else {
          return Container();
        }
      },
    );
  }

  readText() {
    if (play) {
      playPauseController.reverse();
      widget.textRecognizedBloc.play();
    } else {
      playPauseController.forward();
      widget.textRecognizedBloc.pause();
    }
    play = !play;
  }
}
