import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/blocs/bloc_text_recognized_android.dart';
import 'package:mlreader/core/ui/select_view.dart';

class TextRecognized extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TextRecognizedState();
  }
}

class TextRecognizedState extends State<TextRecognized> {
  File pickedImage;
  bool isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    final TextRecognizedBloc textRecognizedBloc =
        BlocProvider.of<TextRecognizedBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("ML Reader"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            RaisedButton(
                child: Text("SCAN"),
                onPressed: () {
                  textRecognizedBloc.pickCamera();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectView(
                              textRecognizedBloc: textRecognizedBloc)));
                }),
            RaisedButton(
                child: Text("SELECT"),
                onPressed: () {
                  textRecognizedBloc.pickGallery();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectView(
                              textRecognizedBloc: textRecognizedBloc)));
                })
          ]),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
