import 'package:flutter/material.dart';
import 'package:home_rental/auth/first_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_rental/main.dart';
import 'package:home_rental/menu/homepage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen after 3 seconds
    var initialzationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS =
    const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var initializationSettings =
    InitializationSettings(android: initialzationSettingsAndroid ,
        iOS: initializationSettingsIOS
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  color: Colors.blue,
                  enableVibration: true,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: "@mipmap/ic_launcher",
                ),
                iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentSound: true,
                    presentBadge: false,
                    sound: 'res_bell.m4a'
                )
              // const DarwinNotificationDetails(
              //     presentAlert: false,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              //     presentBadge: false,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              //     presentSound: true,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              //     // sound: String?,  // Specifics the file path to play (only from iOS 10 onwards)
              //     // badgeNumber: int?, // The application's icon badge number
              //     // attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
              //     // subtitle: String?, //Secondary description  (only from iOS 10 onwards)
              //     // threadIdentifier: String? (only from iOS 10 onwards)
              // )
            ));
      }
      });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body!)],
                ),
              ),
            );
          },);
      }
      });
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirebaseAuth.instance.currentUser == null ?  FirstPage() : HomePage()),
      );
    });
  }
  @override

  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Card(
          elevation: 2,
          child: Container(
            child: Image.asset('assets/icon/rent.png',width: 60,),
          ),
        ),
      ),
    );
  }
}

