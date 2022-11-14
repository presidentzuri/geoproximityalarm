
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoproxyalarm/models/trackmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/foundation.dart';

import '../models/address.dart';

class AppData extends ChangeNotifier {
  Address? deliveryAddress;
  User? currentuserInfo;
  List<String>? myTrackedList=[];
  List<MyTrackUser>? myTrackedListDetailed=[];
  List<MyTrackUser>? trackmeListDetailed=[];


  late bool _isOnline = true;
  bool get isOnline => _isOnline;

  void updateCurrentUserInfo(User users) {
    currentuserInfo = users;
    notifyListeners();
  }
  void updateMyTrackedList(List<String> list) {
    myTrackedList = list;
    notifyListeners();
  }

  void updateMyTrackedDetailedList(List<MyTrackUser> list) {
    myTrackedListDetailed = list;
    notifyListeners();
  }
  void updateTrackMeDetailedList(List<MyTrackUser> list) {
    trackmeListDetailed = list;
    notifyListeners();
  }
  void deleteMyTrackedDetailedList(MyTrackUser object) {
    myTrackedListDetailed?.removeWhere((element) => element.id==object.id);
    notifyListeners();
  }
  void deleteTrackMeDetailedList(MyTrackUser object) {
    trackmeListDetailed?.removeWhere((element) => element.id==object.id);
    notifyListeners();
  }


  void updatedeliveryAddress(Address delivery) {
    deliveryAddress = delivery;

    notifyListeners();
  }

}
