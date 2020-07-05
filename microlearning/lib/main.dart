import 'package:microlearning/screens/AccountManagement/account_settings.dart';
import 'package:microlearning/screens/Decks/notifications_inapp.dart';
import 'package:microlearning/screens/Decks/playlist_manage.dart';
import 'package:microlearning/screens/Search/search.dart';
import 'package:flutter/material.dart';
import 'package:microlearning/screens/authentication/login.dart';
import 'package:microlearning/screens/authentication/register.dart';
import 'package:microlearning/screens/Decks/my_decks.dart';
import 'package:microlearning/screens/authentication/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  return runApp(MyApp(email: email,));
}
class MyApp extends StatelessWidget {
  final email;
  MyApp({@required this.email});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Montserrat'),
      routes: {
        '/': (context) => email == null ? WelcomeScreen() : MyDecks(),
        '/login': (context) => LoginUser(),
        '/home': (context) => MyDecks(),
        '/register': (context) => RegisterUser(),
        '/search': (context) => Search(),
        '/notificationinapp': (context) => NotificationInapp(),
        '/accountsettings': (context) => AccountSettings(),
      },
    );
  }
}
