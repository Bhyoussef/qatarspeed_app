import 'package:flutter/material.dart';

class SlideTransitionsBuilder extends PageTransitionsBuilder {
  const SlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return _ZoomSlideUpTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _ZoomSlideUpTransitionsBuilder extends StatelessWidget {
  _ZoomSlideUpTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  :
        _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kRightLeftTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kRightLeftTween = Tween<Offset>(
    begin: const Offset(.0, 0.0),
    end: const Offset(1.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: child,
    );
  }
}