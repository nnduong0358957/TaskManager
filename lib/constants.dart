import 'package:flutter/material.dart';

const kPrimaryColor = Colors.blue;
const kTextColor = Colors.white;

Container buildColorGradient() {
  return Container(
    decoration: new BoxDecoration(
      gradient: new LinearGradient(
          colors: [
            const Color(0xFF3366FF),
            const Color(0xFF00CCFF),
          ],
          begin: const FractionalOffset(0.0, 1.0),
          end: const FractionalOffset(3.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
    ),
  );
}
