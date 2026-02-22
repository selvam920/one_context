import 'package:flutter/material.dart';
import 'package:one_context/src/controllers/one_context.dart';

class OneContextWidget extends StatefulWidget {
  final Widget? child;
  final MediaQueryData? mediaQueryData;
  final String? initialRoute;
  final List<NavigatorObserver> observers;

  OneContextWidget({
    Key? key,
    this.child,
    this.mediaQueryData,
    this.initialRoute,
    this.observers = const <NavigatorObserver>[],
  }) : super(key: key);
  _OneContextWidgetState createState() => _OneContextWidgetState();
}

class _OneContextWidgetState extends State<OneContextWidget> {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: widget.initialRoute ?? '/',
      observers: [...widget.observers, OneContext().heroController],
      onGenerateRoute: (_) => MaterialPageRoute(
          builder: (context) => Scaffold(
                resizeToAvoidBottomInset: false,
                key: OneContext().scaffoldKey,
                body: widget.child!,
              )),
    );
  }
}
