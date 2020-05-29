import 'package:flutter/material.dart';
import 'package:microlearning/screens/mydecks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetUserInfo extends StatefulWidget {
  @override
  _GetUserInfoState createState() => _GetUserInfoState();
}

class _GetUserInfoState extends State<GetUserInfo> {

  final _formKey = GlobalKey<FormState>();
  String _name;
  String _gender;
  int _grade;

  List<String> genders = ["Male", "Female", "Others"];
  List<String> grades = ["1", "2"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: Form(
          key: _formKey,
          child: Column(
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
                    borderSide: BorderSide(color: Colors.pink, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              DropdownButtonFormField(
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
              SizedBox(height: 20.0,),
              DropdownButtonFormField(
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
              RaisedButton(
                color: Colors.red,
                child: Center(
                  child: Text(
                    "Enter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () async{
                  if(_formKey.currentState.validate()) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String user = prefs.getString('email');

                    //TODO : UPLOAD ALL THIS DATA TO THE DATABASE

                    return MyDecks();
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