import 'package:flutter/material.dart';

class Loading extends StatelessWidget {

  final double size;
  final Color color;

  Loading({@required this.size, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>
          (color),
        strokeWidth: 2,
      ),
    );
  }
}
