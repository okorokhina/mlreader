import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/blocs/bloc_text_recognized_android.dart';
import 'package:mlreader/core/ui/select_view.dart';
import 'package:camera/camera.dart';

class TextRecognized extends StatefulWidget {
  TextRecognized({@required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<StatefulWidget> createState() {
    return TextRecognizedState();
  }
}

class TextRecognizedState extends State<TextRecognized> {
  File pickedImage;
  bool isImageLoaded = false;
  CameraController _controller;
  bool select;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextRecognizedBloc textRecognizedBloc =
        BlocProvider.of<TextRecognizedBloc>(context);
    textRecognizedBloc.scanColor.add(Colors.white);
    textRecognizedBloc.selectColor.add(null);
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text("ML Reader"),
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
                                stream: textRecognizedBloc.outScanColor,
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
                                textRecognizedBloc.scanColor.add(Colors.white);
                                textRecognizedBloc.selectColor.add(null);
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: StreamBuilder(
                                  stream: textRecognizedBloc.outSelectColor,
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
                                textRecognizedBloc.scanColor.add(null);
                                textRecognizedBloc.selectColor
                                    .add(Colors.white);
                                textRecognizedBloc.pickGallery();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectView(
                                            textRecognizedBloc:
                                                textRecognizedBloc)));
                              },
                            ),
                          ),
                        ]),
                  ))),
              cameraScan(),
            ],
          ),
          Positioned(
              child: Center(
            child: Container(
              width: 300,
              height: 300,
              child: Image.asset("assets/CombinedShape.png"),
            ),
          )),
          Positioned(
              top: 550,
              left: 60,
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
                        textRecognizedBloc.takePhoto(context, _controller);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectView(
                                    textRecognizedBloc: textRecognizedBloc)));
                      },
                    ),
                  ])),
        ]));
  }

  cameraScan() {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: CameraPreview(_controller),
    );
  }
}
