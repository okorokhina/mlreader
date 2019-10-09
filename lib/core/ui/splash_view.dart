import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mlreader/core/ui/scan_view.dart';

class SplashView extends StatefulWidget {
  SplashView({@required this.cameras});

  final cameras;

  @override
  State<StatefulWidget> createState() {
    return SplashViewState();
  }
}

class SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    startTimer();
    controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 700));
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text("ML Reader"),
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 55,
              color: Theme.of(context).primaryColor,
            ),
            ScaleTransition(
                scale: controller,
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 50, right: 50, top: 242),
                    child: Image.asset("assets/a5.png"),
                  ),
                )),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              margin: EdgeInsets.only(left: 50, right: 50, top: 132),
              child: Text(
                "Application built with Flutter framework, translates image to text with OCR and reads it aloud.",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ));
  }

  startTimer() async {
    return Timer(Duration(seconds: 2), navigationPage);
  }

  navigationPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TextRecognized(cameras: widget.cameras)));
  }
}
