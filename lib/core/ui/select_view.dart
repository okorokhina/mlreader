import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/ui/progressbar.dart';

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
  // AnimationController parentController;
  AnimationController playPauseController;
  AnimationController songCompletedController;

  Animation<double> songCompletedAnimation;
  Animation<Color> songsContainerTextColorAnimation;

  double soungCompleted = 0.0;
  bool play = false;

  @override
  void initState() {
    super.initState();
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
      body: Column(
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
                                decoration: BoxDecoration(color: snapshot.data),
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
                              stream: widget.textRecognizedBloc.outSelectColor,
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
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(16.5))),
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
    );
  }

  readText() {
      if (play) {
      playPauseController.reverse();
      songCompletedController.stop();
    } else {
      playPauseController.forward();
      songCompletedController.forward();
    }
    play = !play;
  }

  playBack(){
    songCompletedController.stop();
  }
}
