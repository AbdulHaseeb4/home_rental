import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_rental/auth/splashscreen.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_storage/get_storage.dart';

// firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call initializeApp before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

// ✅ Function to Request Permissions Dynamically
Future<void> requestPermissions() async {
  await Permission.camera.request();
  await Permission.storage.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  await requestPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //for not rotating method
  if(Platform.isAndroid){
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }else if(Platform.isIOS){
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  if (details?.didNotificationLaunchApp ?? false) {
    if (details?.notificationResponse?.payload == 'custom') {
      Future.delayed(const Duration(seconds: 4), () {
        //runApp(MyApp(route: customPlanRoute));
      });
      return;
    }
  }


  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => DataProvider(), // ✅ Ensuring DataProvider is available globally
        child: const MyApp(),
      ),
    );
  });
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'testing_channel_1', // id
    'High Importance Notifications', // title
    // description
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('res_bell')
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DataProvider()),
      ],
      child: Builder( // ✅ Use Builder to get correct context
        builder: (context) {
          return Consumer<DataProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                title: 'Flutter Demo',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                  brightness: Brightness.light, // ✅ Light Mode
                  textTheme: const TextTheme(
                    bodyMedium: TextStyle(color: Colors.black), // ✅ Black text in Light Mode
                    bodyLarge: TextStyle(color: Colors.black), // ✅ Ensuring large text is visible
                    titleLarge: TextStyle(color: Colors.black), // ✅ Fix title color in Light Mode
                  ),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark, // ✅ Dark Mode
                  textTheme: const TextTheme(
                    bodyMedium: TextStyle(color: Colors.white), // ✅ White text in Dark Mode
                    bodyLarge: TextStyle(color: Colors.white), // ✅ Ensuring large text is visible
                    titleLarge: TextStyle(color: Colors.white), // ✅ Fix title color in Dark Mode
                  ),
                ),
                themeMode: provider.themeMode, // ✅ Theme updates correctly
                home: SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }

}
