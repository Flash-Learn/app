import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/functions/Infos.dart';
import 'package:microlearning/services/database.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetUserInfo extends StatefulWidget {
  @override
  _GetUserInfoState createState() => _GetUserInfoState();
}

class _GetUserInfoState extends State<GetUserInfo> {

  final _formKey = GlobalKey<FormState>();
  String _name;
  String _gender;
  String _grade;

  List<String> genders = ["Male", "Female", "Others"];
  List<String> grades = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter details",
          style: TextStyle(color: Colors.white),
        ),
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
                  return val.isEmpty ? "Enter name" : null;
                },
                onChanged: (val) {
                  setState(() {
                    _name = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Name",
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
              SizedBox(height: 20.0,),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(  
                      "Gender",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Container(
                      width: 100,
                      child: DropdownButtonFormField(
                        value: _gender ?? "Others",
                        items: genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _gender = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.0,),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Class",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: 100,
                      child: DropdownButtonFormField(
                        value: _grade ?? "1",
                        items: grades.map((grade) {
                          return DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _grade = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.0,),
          
              RaisedButton(
                color: Colors.black,
                child: Center(
                  child: Text(
                    "Enter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () async{
                  if(_formKey.currentState.validate()) {
                    enterInfo(context, {
                      '_name': _name,
                      '_grade': _grade,
                      '_gender': _gender,
                    });
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