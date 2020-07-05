import 'package:flutter/material.dart';
import 'package:microlearning/services/database.dart';
import 'package:microlearning/services/google_signIn.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/AccountManagement/edit_info.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String uid;
  String name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.blue[400],
        centerTitle: true,
        title: Text(
          'Account Settings',
          style: TextStyle(
              color: MyColorScheme.uno(), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: MyColorScheme.uno(),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.blue[600],
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              CircleAvatar(
                backgroundImage: AssetImage('assets/userprofile.png'),
                radius: 40,
                backgroundColor: Colors.white,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              // Text(
              //   'NAME',
              //   style: TextStyle(
              //     color: Colors.white,
              //     letterSpacing: 2.0,
              //   ),
              // ),
              SizedBox(height: 10),
              FutureBuilder(
                  future: _getdatafromdatabase(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Text("loading");
                    // print('hahah $name');
                    return Text(
                      name,
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: MediaQuery.of(context).size.width * 0.2),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColorScheme.accent(),
                  child: InkWell(
                    splashColor: Colors.grey,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => EditInfo()));
                    },
                    child: Container(
                      height: 40,
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        // color: Colors.transparent,
                        color: Color.fromRGBO(50, 187, 157, 1),
                        child: Center(
                          child: Text('Update Info',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: MediaQuery.of(context).size.width * 0.2),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColorScheme.accent(),
                  child: InkWell(
                    splashColor: Colors.grey,
                    onTap: () {
                      signOutGoogle();
                      return Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                          return LoginUser();
                        }),
                        ModalRoute.withName('/login'),
                      );
                    },
                    child: Container(
                      height: 40,
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromRGBO(50, 187, 157, 1),
                        child: Center(
                          child: Text('Log Out',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Future<String> _getdatafromdatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
    DataBaseServices here;
    here = DataBaseServices(uid: uid);
    List<String> defaults = await here.getData();
    //TODO: fix default values of this form
    if (defaults.length > 1 || here != null) {
      name = defaults[0];
    }
    return defaults.toString();
  }
}
