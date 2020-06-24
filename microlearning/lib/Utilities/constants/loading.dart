import 'package:flutter/material.dart';

class Loading extends StatelessWidget {

  final double size;

  Loading({@required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>
          (Colors.white),
        strokeWidth: 2,
      ),
    );
  }
}
