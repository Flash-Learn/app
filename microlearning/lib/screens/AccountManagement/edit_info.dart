import 'package:flutter/material.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:microlearning/Utilities/constants/inputTextDecorations.dart';
import 'package:microlearning/Utilities/functions/Infos.dart';
import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_settings.dart';

class EditInfo extends StatefulWidget {
  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  final _formKey = GlobalKey<FormState>();
  String _uid;
  String _name;
  String _grade;
  String _gender;
  bool bool1;

  List<String> genders = ["Male", "Female", "Others"];
  List<String> grades = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];

  @override
  void initState() {
    bool1 = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _getdatafromdatabase(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Edit Information"),
              backgroundColor: MyColorScheme.accent(),
            ),
            backgroundColor: Colors.white,
            body: Container(
              padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                        initialValue: _name,
                        validator: (val) {
                          return val.isEmpty ? "Enter name" : null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _name = val;
                          });
                        },
                        decoration: inputTextDecorations("Name")),
                    SizedBox(
                      height: 20.0,
                    ),
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
                              value: _gender,
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
                    SizedBox(
                      height: 20.0,
                    ),
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
                              value: _grade,
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
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      elevation: 2,
                      color: MyColorScheme.accent(),
                      child: Center(
                        child: Text(
                          "Enter",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          updateInfo({
                            '_uid': _uid,
                            '_name': _name,
                            '_gender': _gender,
                            '_grade': _grade,
                          });
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return AccountSettings(
                              name: _name,
                            );
                          }));
                          // Navigator.of(context).pushAndRemoveUntil(
                          // MaterialPageRoute(builder: (context) {
                          //   return AccountSettings(name: _name,);
                          // }), ModalRoute.withName('/home'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            ),
          );
        }
      },
    );
  }

  Future<String> _getdatafromdatabase() async {
    if (bool1 == false) {
      bool1 = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _uid = prefs.getString('uid');
      DataBaseServices here;
      here = DataBaseServices(uid: _uid);
      List<String> defaults = await here.getData();
      //TODO: fix default values of this form
      if (defaults.length > 1 || here != null) {
        _name = defaults[0];
        _grade = defaults[1];
        _gender = defaults[2];
      }
      return defaults.toString();
    } else {
      return 'this is good';
    }
  }
}
