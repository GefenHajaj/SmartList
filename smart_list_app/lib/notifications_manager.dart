import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsManager {
  static final NotificationsManager _notificationService = NotificationsManager._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  factory NotificationsManager() {
    return _notificationService;
  }

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('cart_icon');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings
    );
  }

  Future<void> scheduleNotifications() async {
    // First, cancel every pending notifications
    await flutterLocalNotificationsPlugin.cancelAll();

    // Add notification
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Super List',
        'היי, מזכיר שאם צריך לעשות קניות אני פה!',
        RepeatInterval.weekly,
        const NotificationDetails(
            android: AndroidNotificationDetails('myChannelID1726275',
                'SuperListChannelName', 'Super List Channel'),
        ),
        androidAllowWhileIdle: true,
    );
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     0,
    //     'Super List',
    //     'היי, מזכיר שאם צריך לעשות קניות אני פה!',
    //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    //     const NotificationDetails(
    //         android: AndroidNotificationDetails('myChannelID1726275',
    //             'SuperListChannelName', 'Super List Channel'),
    //     ),
    //     androidAllowWhileIdle: true,
    //     uiLocalNotificationDateInterpretation:
    //     UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future onSelectNotification(String payload) async {
    print("Got here from notification");
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    print("Got here from notification");
  }


  NotificationsManager._internal();
}