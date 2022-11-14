import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackMeUser{
  String? userName;
  String? imgUrl;
  double? distance;
  LatLng? location;
  String? status;

  TrackMeUser({this.distance,this.location,this.imgUrl,this.userName});


}

class MyTrackUser{
  String? id;
  String? userName;
  String? imgUrl;
  double? distance;
  GeoPoint? location;
  String? placeName;
  String? status;
  String? tracker_id;
  String? tracked_id;
  MyTrackUser({this.distance,this.location,this.imgUrl,this.userName,this.status,this.placeName,this.tracker_id});

  MyTrackUser.fromSnapshot(DocumentSnapshot snapshot){
   userName=snapshot.get('name');
   imgUrl=snapshot.get('image');
   distance=double.parse(snapshot.get('distance').toString());
   location=snapshot.get('position');
   status =snapshot.get('status');
   placeName=snapshot.get('place');
   tracker_id=snapshot.get('tracker_id');
   tracked_id=snapshot.get('tracked_id');
   id=snapshot.id;

  }

}