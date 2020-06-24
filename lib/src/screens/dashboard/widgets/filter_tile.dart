import 'package:flutter/material.dart';

class FilterTile extends StatelessWidget {
  FilterTile({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 20,
        bottom: 20,
        left: 24,
        right: 24
      ),
      child: child,
    );
  }
}