import 'package:flutter/material.dart';
import 'package:microlearning/Models/group.dart';
import 'package:microlearning/screens/Groups/my_groups.dart';

class InitGroup extends StatefulWidget {
  final GroupData groupData;
  InitGroup({Key key, @required this.groupData}) : super(key: key);
  @override
  _InitGroupState createState() => _InitGroupState(groupData: groupData);
}

class _InitGroupState extends State<InitGroup> {
  final _formKey = GlobalKey<FormState>();
  GroupData groupData;
  _InitGroupState({@required this.groupData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create groups",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                validator: (val) {
                  return val.isEmpty ? "Enter group name" : null;
                },
                onChanged: (val) {
                  setState(() {
                    groupData.name = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Group name",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(12.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                validator: (val) {
                  return val.isEmpty ? "Enter group description" : null;
                },
                onChanged: (val) {
                  setState(() {
                    groupData.description = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Group description",
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(12.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              RaisedButton(
                color: Colors.black,
                child: Center(
                  child: Text(
                    'Create group!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await updateGroupData(groupData);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                      return GroupList();
                    }));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
