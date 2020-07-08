import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var i = -999999;

class Notifications {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_launcher');
    var initializeIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings);
  }

  Future singleNotification(DateTime datetime, String message, String subtext,
      {String sound}) async {
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidChannel = AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
      playSound: true,
      importance: Importance.Max,
      vibrationPattern: vibrationPattern,
      ongoing: true,
      enableLights: true,
      priority: Priority.Max,
    );

    if (i == 999999) {
      i = -999999;
    }
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    await localNotificationsPlugin.schedule(
        i++, message, subtext, datetime, platformChannel);
  }
}
