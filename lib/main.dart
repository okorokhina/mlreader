import 'package:flutter/material.dart';
import 'package:mlreader/core/blocs/bloc_provider.dart';
import 'package:mlreader/core/blocs/bloc_text_recognized_android.dart';
import 'package:mlreader/core/ui/scan_view.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            appBarTheme: AppBarTheme(color: Color(0xFF00B33A)),
            primaryColor: Color(0xFF00B33A)),
        home: BlocProvider(
            bloc: TextRecognizedBloc(),
            child: TextRecognized(cameras: cameras)));
  }
}
