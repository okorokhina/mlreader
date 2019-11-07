import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagetospeech/core/blocs/bloc_provider.dart';
import 'package:imagetospeech/core/blocs/bloc_text_recognized.dart';
import 'package:camera/camera.dart';
import 'package:imagetospeech/core/ui/splash_view.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocProvider(
        bloc: TextRecognizedBloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
            title: 'Image to Speech',
            theme: ThemeData(
                appBarTheme: AppBarTheme(color: Color(0xFF00B33A)),
                primaryColor: Color(0xFF00B33A)),
            home: Scaffold(body: SplashView(cameras: cameras))));
  }
}
