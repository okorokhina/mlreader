import 'package:flutter/material.dart';
import 'package:imagetospeech/core/ui/select_view.dart';

class PhotoButton extends StatelessWidget {
  final bottom;
  final controller;
  final textRecognizedBloc;

  PhotoButton(
      {@required this.bottom, this.controller, this.textRecognizedBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: bottom, left: 10, right: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 300,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Center(
                          child: Text(
                        "Please scan the text you want to read",
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                    onTap: () {
                      textRecognizedBloc.takePhoto(context, controller);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectView(
                                  textRecognizedBloc: textRecognizedBloc)));
                    },
                  ),
                ])),
      ],
    );
  }
}
