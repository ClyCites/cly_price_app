import 'package:flutter/material.dart';

class CustomNavigator extends StatelessWidget {
  final Widget child;
  
  const CustomNavigator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return child;
          },
        );
      },
    );
  }
}

