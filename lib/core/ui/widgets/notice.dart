import 'package:flutter/material.dart';

class Notice extends StatelessWidget {
  final textRecognizedBloc;

  Notice({@required this.textRecognizedBloc});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: textRecognizedBloc.outNoticeOpacity,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return AnimatedOpacity(
              opacity: snapshot.data,
              duration: Duration(seconds: 1),
              child: TickerMode(
                  enabled: false,
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        width: 150,
                        height: 50,
                        child: Center(
                            child: Text(
                          "Audio saved",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ))),
                  )));
        } else {
          return Container();
        }
      },
    );
  }
}
