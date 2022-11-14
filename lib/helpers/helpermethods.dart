

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoproxyalarm/helpers/requesthelper.dart';
import 'package:geoproxyalarm/models/trackmodel.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../globalvariables.dart';
import '../models/address.dart';
import '../providers/appdata.dart';

class HelperMethods{

  static  double getTextSize(double sysVar,double size){
    double calc=size/10;
    return sysVar *calc;
  }
  static String formatMyDate(String datestring){
    print(datestring);
    DateTime thisdate = DateTime.parse(datestring);
    String formattedDate ='${DateFormat.MMMd().format(thisdate)}, ${DateFormat.y().format(thisdate)} - ${DateFormat.jm().format(thisdate)}';
    return formattedDate;
  }

  static Future<String> findCoordinateAddress(Position position,context) async{

    String placesAddress = "";
    // check network connectivity
    bool result = await InternetConnectionChecker().hasConnection;
    if(result == true) {
      String url ="https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
      var response = await RequestHelper.getRequest(url);
      if(response!='failed'){
        placesAddress = response['results'][0]['formatted_address'];
        Address deliveryAddress =Address(placename: placesAddress,placeformattedAddress: "",placeId: "",latitude: position.latitude,longitude: position.longitude);

        Provider.of<AppData>(context,listen: false). updatedeliveryAddress(deliveryAddress);


      }
    } else {
      Fluttertoast.showToast(msg: 'No internet connection!');

      print('No internet :( Reason:');

    }
    return placesAddress;
  }


  static fetchmyTrackInfo(String orderId, context) async{
      EasyLoading.show( status: 'Getting details...');

    await FirebaseFirestore.instance.collection('mytrack').doc(orderId).get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        currenttrackinfo=MyTrackUser.fromSnapshot(documentSnapshot);
        // TODO: complete New notification dialog
       EasyLoading.dismiss();


      }else{
        Fluttertoast.showToast(
            msg: 'Fetching timed out',
            textColor: Colors.white,
            backgroundColor: Colors.redAccent);
        EasyLoading.dismiss();
        return;
      }

    }).timeout(Duration(seconds: 20));


  }

 static num calculateDistance(Position currentposition, MyTrackUser probePosition) {
    var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
        LatLng(currentposition.latitude, currentposition.longitude),
        LatLng(probePosition.location!.latitude, probePosition.location!.longitude));
    return distanceBetweenPoints;
  }
}