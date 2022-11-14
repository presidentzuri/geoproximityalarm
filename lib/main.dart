import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoproxyalarm/providers/appdata.dart';
import 'package:geoproxyalarm/screens/Notificationscreen.dart';
import 'package:geoproxyalarm/screens/flashscreen.dart';
import 'package:geoproxyalarm/screens/homepage.dart';
import 'package:geoproxyalarm/screens/mytracklist.dart';
import 'package:geoproxyalarm/screens/setlocationscreen.dart';
import 'package:geoproxyalarm/screens/trackingme.dart';
import 'package:provider/provider.dart';

import 'globalvariables.dart';

Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCCFTG-FOKhaqUy1l-BInpN5PQ6LftjGmc',
      appId: '1:156575305688:android:6be6456a27e9a6c5376cad',
      messagingSenderId: '156575305688',
      projectId: 'geoproximityalarm',
      databaseURL: 'https://geoproximityalarm-default-rtdb.firebaseio.com',
      storageBucket: 'geoproximityalarm.appspot.com',
    ),
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        initialRoute: FlashScreen.id,
        builder: EasyLoading.init(),
        theme: ThemeData( fontFamily: 'Brand-Regular',
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
   routes: {
       FlashScreen.id: (context) => FlashScreen(),
       MyHomePage.id: (context) => MyHomePage(),
       MyTrackedScreen.id:(context)=>MyTrackedScreen(),
       TrackMeScreen.id:(context)=>TrackMeScreen(),
       SelectMap.id:(context)=>SelectMap(),
       NotificationPage.id:(context)=>NotificationPage()
   },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {


  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  AwesomeNotifications().createNotificationFromJsonData(message.data);
  AssetsAudioPlayer assetAudioPlayer=AssetsAudioPlayer();
  print("Handling a background message: ${message.messageId}");
  assetAudioPlayer.open(Audio('sounds/bellsound.wav'));
  assetAudioPlayer.play();

}