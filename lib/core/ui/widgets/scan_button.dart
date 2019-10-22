import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final textRecognizedBloc;
  final onTap;

  ScanButton({@required this.textRecognizedBloc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: SizedBox(
            child: StreamBuilder(
          stream: textRecognizedBloc.outScanColor,
          builder: (context, snapshot) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: snapshot.data),
              child: Text("SCAN"),
            );
          },
        )),
        onTap: onTap,
      ),
    );
  }
}
