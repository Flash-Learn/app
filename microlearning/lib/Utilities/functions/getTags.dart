import 'package:flutter/material.dart';

List<Widget> getTags(List<dynamic> strings) {
  List<Widget> ret = [];
  for (var i = 0; i < strings.length; i++) {
    ret.add(Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: (i % 2 == 0)
            ? Color.fromRGBO(242, 201, 76, 1)
            : Color.fromRGBO(187, 107, 217, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          strings[i],
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            fontSize: 15,
          ),
        ),
      ),
    ));
    ret.add(SizedBox(
      width: 5,
    ));
  }
  return ret;
}
