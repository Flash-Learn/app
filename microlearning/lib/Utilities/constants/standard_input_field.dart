import 'package:flutter/material.dart';

class StandardInputField extends StatelessWidget
{
  // final Function onChanged;
  final labelText;
  StandardInputField(this.labelText);

  @override
  Widget build(BuildContext context)
  {
    return TextField(
      // onChanged: this.onChanged,
      decoration: InputDecoration(
        labelText: this.labelText,
        labelStyle: TextStyle(color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.all(20.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }
}