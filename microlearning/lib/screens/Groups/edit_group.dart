import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';

class EditGroup extends StatefulWidget {
  final GroupData groupData;
  bool creating;
  EditGroup({Key key, @required this.groupData, this.creating: false})
      : super(key: key);
  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
