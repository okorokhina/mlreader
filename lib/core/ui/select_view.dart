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
                decoration: BoxDecoration(
                    image: DecorationImage(image: FileImage(snapshot.data))),
              );
            } else {
              return Text("Choise image");
            }
          },
        ),
      ),
    );
  }
}
