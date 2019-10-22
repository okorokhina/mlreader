import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/resourses/TextToSpeechAPI.dart';
import 'package:mlreader/core/resourses/text_to_sound.dart';
import 'package:mlreader/core/ui/progressbar.dart';
import 'package:mlreader/core/ui/widgets/internet_connection.dart';

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
                          Expanded(
                            child: GestureDetector(
                              child: SizedBox(
                                  child: StreamBuilder(
                                stream: widget.textRecognizedBloc.outScanColor,
                                builder: (context, snapshot) {
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: snapshot.data),
                                    child: Text("SCAN"),
                                  );
                                },
                              )),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.textRecognizedBloc.scanColor
                                    .add(Colors.white);
                                widget.textRecognizedBloc.selectColor.add(null);
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: StreamBuilder(
                                  stream:
                                      widget.textRecognizedBloc.outSelectColor,
                                  builder: (context, snapshot) {
                                    return Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: snapshot.data,
                                      ),
                                      child: Text("SELECT"),
                                    );
                                  }),
                              onTap: () {
                                widget.textRecognizedBloc.scanColor.add(null);
                                widget.textRecognizedBloc.selectColor
                                    .add(Colors.white);
                                widget.textRecognizedBloc.pickGallery();
                              },
                            ),
                          ),
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
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: DropdownButton<Voice>(
                        value: _selectedVoice,
                        hint: Text('Select Voice'),
                        items: _voices.map((f) => DropdownMenuItem(
                          value: f,
                          child: Text('${f.name} - ${f.languageCodes.first} - ${f.gender}'),
                        )).toList(),
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
                      child: CustomPaint(
                        painter: ProgressBar(
                            context: context, songCompleted: soungCompleted),
                      ),
                    ))
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: bottom),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/Download.png"),
                      SizedBox(width: 5),
                      Text("Save to file storage")
                    ],
                  ))
            ],
          ),
          Positioned(
            child: InternetConnection(
                textRecognizedBloc: widget.textRecognizedBloc),
          )
        ]));
  }

  void getVoices() async {
    final voices = await TextToSpeechAPI().getVoices();
    if (voices == null) return;
    setState(() {
      _selectedVoice = voices.firstWhere((e) => e.name == 'en-US-Wavenet-F' && e.languageCodes.first == 'en-US', orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
      _voices = voices;
    });
  }

  readText() {
    if (play) {
      playPauseController.reverse();
      songCompletedController.stop();
      textToSound.sppek.add("play");
      textToSound.stop("play");
    } else {
      textToSound.stop("play");
      textToSound.sppek.add("play");
      playPauseController.forward();
      songCompletedController.forward();
    }
    play = !play;
  }

  playBack() {
    songCompletedController.stop();
  }
}
