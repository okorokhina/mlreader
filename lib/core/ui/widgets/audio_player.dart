import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';

class MLAudioPlayer extends StatefulWidget {
  final textRecognizedBloc;

  MLAudioPlayer({
    @required this.textRecognizedBloc,
  });

  @override
  State<StatefulWidget> createState() {
    return MLAudioPlayerState();
  }
}

class MLAudioPlayerState extends State<MLAudioPlayer>
    with TickerProviderStateMixin {
  bool play = false;
  Duration duration;
  Duration position;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  AnimationController playPauseController;

  @override
  void initState() {
    // Animation for Play and Pause Buttons
    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    // Listen the audio and set a new audio position
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
    super.initState();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.textRecognizedBloc.audio != null
        ? Container(
            margin: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: <Widget>[
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(16.5))),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        icon: Image.asset("assets/RewindBack.png"),
                        onPressed: () {
                          widget.textRecognizedBloc
                              .rewind(position?.inSeconds?.toDouble());
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
                          widget.textRecognizedBloc
                              .fastForward(position?.inSeconds?.toDouble());
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
                          ? position?.inMilliseconds?.toDouble() ?? 0.0
                          : 0.0,
                      onChanged: (double value) =>
                          widget.textRecognizedBloc.audioPosition(value),
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
          );
  }

  // Change buttons Play and Pause
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
