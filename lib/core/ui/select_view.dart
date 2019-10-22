import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/resourses/TextToSpeechAPI.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';
import 'package:mlreader/core/ui/progressbar.dart';
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
  AnimationController playPauseController;
  AnimationController songCompletedController;

  Animation<double> songCompletedAnimation;
  Animation<Color> songsContainerTextColorAnimation;

  AudioPlayer audioPlayer;

  double soungCompleted = 0.0;
  bool play = false;
  final textToSound = TextToSound();
  List<Voice> _voices = [];
  Voice _selectedVoice;

  @override
  void initState() {
    super.initState();
    getVoices();
    songCompletedController =
        AnimationController(vsync: this, duration: Duration(seconds: 10))
          ..addListener(() {
            setState(() {
              soungCompleted = songCompletedAnimation.value;
            });
          });

    songCompletedAnimation =
        Tween<double>(begin: 0.0, end: 330).animate(songCompletedController);
    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
                            },
                          ),
                          SelectButton(
                              textRecognizedBloc: widget.textRecognizedBloc,
                              onTap: () {
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
              Container(
                margin: EdgeInsets.only(left: 40, right: 40),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.5))),
                      margin: EdgeInsets.only(bottom: 80),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset("assets/RewindBack.png"),
                            onPressed: () {
                              songCompletedController.reverse();
                              // Timer(Duration(seconds: 2), playBack());
                            },
                          ),
                          InkWell(
                              onTap: () {
                                readText();
                                // widget.textRecognizedBloc.play();
                                // textRecognizedBloc.stop("play");
                              },
                              child: Material(
                                  child: AnimatedIcon(
                                size: 30,
                                color: Theme.of(context).primaryColor,
                                icon: AnimatedIcons.play_pause,
                                progress: playPauseController,
                              ))),
                          IconButton(
                            icon: Image.asset("assets/Rewind.png"),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                        },
                      ),
                    ),
                    Center(
                        child: Container(
                      width: MediaQuery.of(context).size.width,
                      //           duration == null
                      // ? new Container()
                      // : new Slider(
                      //     value: position?.inMilliseconds?.toDouble() ?? 0.0,
                      //     onChanged: (double value) =>
                      //         audioPlayer.seek((value / 1000).roundToDouble()),
                      //     min: 0.0,
                      //     max: duration.inMilliseconds.toDouble()),
                      // child: CustomPaint(
                      //   painter: ProgressBar(
                      //       context: context, songCompleted: soungCompleted),
                      // ),
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 50,
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
      songCompletedController.forward();
      widget.textRecognizedBloc.play();
    } else {
      songCompletedController.stop();
      playPauseController.forward();
      widget.textRecognizedBloc.pause();
    }
    play = !play;
  }

  playBack() {
    songCompletedController.stop();
  }
}
