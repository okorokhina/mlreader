import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressBar extends CustomPainter{

  var songCompleted;
  var context;
  // var progresBarColor;

  ProgressBar({this.songCompleted, this.context});
  
  @override
  void paint(Canvas canvas, Size size) {
    var songProgressBar = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

    var progressIndicator = Paint()
    ..color = Theme.of(context).primaryColor;

    var songProgressBarCompleted = Paint()
    ..color = Theme.of(context).primaryColor
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width - size.width, 0), Offset(size.width, 0), songProgressBar);
    canvas.drawCircle(Offset(this.songCompleted,0), 7.0, progressIndicator);
    canvas.drawLine(Offset(0,0), Offset(this.songCompleted,0), songProgressBarCompleted);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}