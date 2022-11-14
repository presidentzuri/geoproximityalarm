


import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoproxyalarm/models/trackmodel.dart';


Position? currentPosition;
String? finalAddress;
double? selectedDistance;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
MyTrackUser? currenttrackinfo;
late StreamSubscription<Position> homeTabPositionStream;
var locationOptions = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);
var lac=LocationAccuracy.bestForNavigation;
String mapKey = "<YOUR MAP KEY>";
String token='<FIREBASE CLOUD MESSAGING KEY>';
