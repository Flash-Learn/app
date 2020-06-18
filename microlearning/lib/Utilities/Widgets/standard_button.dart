import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget
{

  // final Function onTapFunc;
  final Widget content;

  StandardButton(this.content);

  @override
  Widget build(BuildContext context)
  {
    return Material(
      borderRadius: BorderRadius.circular(5),
      color: Colors.black,
      child: InkWell(
        splashColor: Colors.grey,
        // onTap: () async {
        //   this.onTapFunc();
        // },
        child: Container(
          height: 40,
          child: Material(
            borderRadius: BorderRadius.circular(5),
            color: Colors.transparent,
            child: Center(
              child: this.content
            ),
          ),
        ),
      ),
    );
  }
}