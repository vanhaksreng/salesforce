import 'package:flutter/material.dart';

class RouteST {
  static SlideTransition st(
    animation,
    child, {
    double begin = 1,
    double end = 0,
  }) {
    final tween = Tween(begin: Offset(begin, end), end: Offset.zero);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.ease,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}
