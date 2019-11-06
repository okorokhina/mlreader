import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/ads_bloc.dart';
import 'package:mlreader/core/blocs/bloc_text_recognized.dart';
import 'package:camera/camera.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:mlreader/core/ui/widgets/internet_connection.dart';
import 'package:mlreader/core/ui/widgets/photo_button.dart';
import 'package:mlreader/core/ui/widgets/scan_button.dart';
import 'package:mlreader/core/ui/widgets/select_button.dart';

class TextRecognized extends StatefulWidget {
  TextRecognized({@required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<StatefulWidget> createState() {
    return TextRecognizedState();
  }
}

class TextRecognizedState extends State<TextRecognized> {
  CameraController controller;
  final textRecognizedBloc = TextRecognizedBloc();
  final adsBloc = AdsBloc();
  double bottom;

  @override
  void initState() {
    super.initState();
    adsBloc.adsBanner();
    textRecognizedBloc.scanColor.add(Colors.white);
    textRecognizedBloc.selectColor.add(null);

    // Initialize the first phone camera
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Device.get().isIphoneX ? bottom = 110 : bottom = 80;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
                          ScanButton(
                              textRecognizedBloc: textRecognizedBloc,
                              onTap: () {
                                textRecognizedBloc.scanColor.add(Colors.white);
                                textRecognizedBloc.selectColor.add(null);
                              }),
                          SelectButton(
                              textRecognizedBloc: textRecognizedBloc,
                              onTap: () async {
                                textRecognizedBloc.scanColor.add(null);
                                textRecognizedBloc.selectColor
                                    .add(Colors.white);
                                textRecognizedBloc.pickGallery(
                                    context, textRecognizedBloc, true);
                              })
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
          PhotoButton(
            bottom: bottom,
            controller: controller,
            textRecognizedBloc: textRecognizedBloc,
          ),
          Positioned(
              child: InternetConnection(textRecognizedBloc: textRecognizedBloc))
        ]));
  }

  // Open the camera if it is initialized
  cameraScan() {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Expanded(
      child: Container(child: CameraPreview(controller)),
    );
  }
}
