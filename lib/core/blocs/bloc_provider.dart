import 'package:flutter/material.dart';

abstract class BlocBase{
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget{

  BlocProvider({Key key, @required this.child, @required this.bloc}): super (key: key);

  final T bloc;
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return BlocProviderState();
  }

  static T of <T extends BlocBase>(BuildContext context){
    final type = _typeOf<BlocProvider<T>>();
    BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }
  static Type _typeOf<T>() => T;
}

class BlocProviderState extends State<BlocProvider<BlocBase>>{
    @override
  void dispose(){
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}