import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class InternetConnection extends StatefulWidget {
  final textRecognizedBloc;

  InternetConnection({@required this.textRecognizedBloc});

  @override
  State<StatefulWidget> createState() {
    return InternetConnectionState();
  }
}

class InternetConnectionState extends State<InternetConnection> {
  var subscription;

  @override
  void initState() {
    /* Listen to the internet connection and show or hide the message 
    when not internet connectivity. */

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.mobile &&
          result != ConnectivityResult.wifi) {
        widget.textRecognizedBloc.internetConnect.add("No internet connection");
      } else {
        widget.textRecognizedBloc.internetConnect.add(null);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.textRecognizedBloc.outInternetConnect,
      builder: (context, snapshot) {
        return snapshot.data != null
            ? Center(
                child: Container(
                margin:
                    EdgeInsets.only(top: 20, bottom: 70, left: 20, right: 20),
                decoration: BoxDecoration(color: Colors.grey[200]),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Text(
                    snapshot.data,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ))
            : Container();
      },
    );
  }
}
