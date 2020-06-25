import 'package:flutter/material.dart';
import 'package:microlearning/services/google_signIn.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/AccountManagement/edit_info.dart';
import 'package:microlearning/Utilities/constants/color_scheme.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Account Settings', style: TextStyle(color: MyColorScheme.cinco(), fontWeight: FontWeight.bold),),
        backgroundColor: MyColorScheme.uno(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
            color: MyColorScheme.accent(),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width * 0.2),
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
                      color: Colors.transparent,
                      child: Center(
                        child: Text('Update Info',
                            style: TextStyle(fontSize: 14, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Padding(
              padding:  EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width * 0.2),
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
                      color: Colors.transparent,
                      child: Center(
                        child: Text('Log Out',
                            style: TextStyle(fontSize: 14, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
