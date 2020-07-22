import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Random random = new Random();
var i = random.nextInt(999999999);

class Notifications {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var i2 = i++;

  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_launcher');
    var initializeIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings);
  }

  requestIOSPermission() {
    localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
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

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    await localNotificationsPlugin.schedule(
        i2, message, subtext, datetime, platformChannel);
  }

  Future cancelNotifications() async {
    await localNotificationsPlugin.cancel(i2);
  }
}
