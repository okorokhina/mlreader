import 'package:flutter/material.dart';
import 'package:mlreader/core/ui/select_view.dart';

class SelectButton extends StatelessWidget {
  final textRecognizedBloc;
  final onTap;

  SelectButton({@required this.textRecognizedBloc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
        onTap: onTap,
      ),
    );
  }
}
