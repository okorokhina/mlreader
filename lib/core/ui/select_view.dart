import 'dart:io';
import 'package:flutter/material.dart';

class SelectView extends StatefulWidget {
  SelectView({@required this.textRecognizedBloc});

  final textRecognizedBloc;

  @override
  State<StatefulWidget> createState() {
    return SelectViewState();
  }
}

class SelectViewState extends State<SelectView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ML Reader"),
      ),
      body: Container(
        child: StreamBuilder(
          stream: widget.textRecognizedBloc.outPhoto,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 100),
                decoration: BoxDecoration(
                    image:
                        DecorationImage(image: FileImage(File(snapshot.data)))),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
