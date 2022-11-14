

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geoproxyalarm/globalvariables.dart';
import 'package:geoproxyalarm/helpers/helpermethods.dart';
import 'package:geoproxyalarm/widgets/alarmdialogue.dart';
import 'package:provider/provider.dart';

import '../providers/appdata.dart';
import '../widgets/notificationdialogue.dart';



class PushNotificationService {

  User? user;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  AssetsAudioPlayer? assetAudioPlayer;

  Future initialize(context) async {
    assetAudioPlayer=AssetsAudioPlayer();
   user = Provider.of<AppData>(context, listen: false).currentuserInfo;
    var settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    // local notification

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var data = message.data;
      var notification = message.notification;
      String? messages = notification!.body;
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');


      if (message.notification != null) {
        assetAudioPlayer?.open(Audio('sounds/bellsound.wav'));
        assetAudioPlayer?.play();

        AwesomeNotifications().createNotificationFromJsonData(message.data);
        print('Message also contained a notification: ${notification}');
      }

      String? trackid=data['trackid'];
      if(trackid!=null){
        await HelperMethods.fetchmyTrackInfo(trackid, context);
        if(currenttrackinfo!=null){
          showDialog(context: context,
              barrierDismissible: false,
              builder:(BuildContext context)=> NotificationDialogManual(currenttrackinfo!));
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)async {
      var data = message.data;
      var notification = message.notification;

      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        /*
        AwesomeNotifications().createNotification(content: NotificationContent(
          id: 10,
          channelKey: channel.id,
          title: notification?.title,
          body: notification?.body,
        ));
        */
         String? trackid=data['trackid'];
         String? status=data['status'];
        if(trackid!=null && status==null){
         await HelperMethods.fetchmyTrackInfo(trackid, context);
         if(currenttrackinfo!=null){
           showDialog(context: context,
               barrierDismissible: false,
               builder:(BuildContext context)=> NotificationDialogManual(currenttrackinfo!));
         }
        }else{
          await HelperMethods.fetchmyTrackInfo(trackid!, context);
          if(currenttrackinfo!=null){
            showDialog(context: context,
                barrierDismissible: false,
                builder:(BuildContext context)=> AlarmDialogManual(currenttrackinfo!));
          }
        }
        AwesomeNotifications().createNotificationFromJsonData(message.data);
        print('Message also contained a notification: ${notification}');
      }
      if (data['status'] == 'arrived') {


      }
      print('A new onMessageOpenedApp event was published!${message.data}');
    });
  }

  Future<String?> getToken() async {
    String? token = await fcm.getToken();
    print(token);

     FirebaseFirestore.instance.collection('users').doc(user?.uid).update(
         {'token': token!});

    fcm.subscribeToTopic('allusers');
  }

}
