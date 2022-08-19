import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PersistentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a command...',
        ),
      ),
      centerTitle: true,
    );
  }
}

class BaseWidget extends StatelessWidget {
  final Widget child;

  const BaseWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          PersistentWidget(),
        ],
      ),
    );
  }
}
