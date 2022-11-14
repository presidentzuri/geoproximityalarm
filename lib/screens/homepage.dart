import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoproxyalarm/brand_colors.dart';
import 'package:geoproxyalarm/widgets/app_drawer.dart';
import 'package:location/location.dart' hide LocationAccuracy ;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

import '../globalvariables.dart';
import '../helpers/helpermethods.dart';
import '../helpers/pushnotificationservice.dart';
import '../models/trackmodel.dart';
import '../models/usermodels.dart';
import '../providers/appdata.dart';



class MyHomePage extends StatefulWidget {
  static const String id = '/';
  MyHomePage({Key? key, this.title,this.user}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  String? title;
  User? user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _messageCount = 0;
  // Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  late String documentid='';
  late String checkStatus;


  int _counter = 0;
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  double mapBottomPadding = 0;
  var geolocator = Geolocator();
  bool? expandedFab = false;
  bool? isOnline=false;
  double _fabHeight = 170;
  var locationOptions = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);
  Icon locationIcon = Icon(
    Icons.location_disabled_rounded,
    color: Colors.black26,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void _currentLocation() async {

    if(!mounted){
      return;
    }
    final GoogleMapController controller = await _controller.future;
    LocationData? currentLocation;
    var location = Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation!.latitude!, currentLocation.longitude!),
        zoom: 17.0,
      ),
    ));

    setupPositionLocator();
  }

  void setupPositionLocator() async {
    if(!mounted){return;}
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    var location = Location();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if(!mounted){return;}
    setState(() {
      locationIcon = Icon(
        Icons.my_location,
        color: Colors.black45,
      );
    });



    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    LatLng pose = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pose, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    // print('current location is: ${position.latitude}${position.longitude}');

/*    startGeoFireListener(
        LatLng(customLatLng().latitude, customLatLng().longitude));*/
    /*   String address =
    await HelperMethods.findCoordinateAddress(position, context);*/

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
      await getMyTrack();
    });

  }
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.height * 0.01;
    final ThemeData _theme = Theme.of(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(backgroundColor: _theme.scaffoldBackgroundColor,
      key: scaffoldkey,
      drawer: AppDrawer(),
      body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding, top: 80),
              mapType: MapType.normal,
              initialCameraPosition: _kLake,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              mapToolbarEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              //  polylines: _polyline,
              // circles: _circles,
              //markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                if(mounted){
                  _controller.complete(controller);
                  mapController = controller;
                  /* setState(() {
                mapBottomPadding = bottomPanel + 10;
              });
            */

                }
                setupPositionLocator();

                Future.delayed(Duration(seconds: 4), () {
                  _currentLocation();
                });

                // getPlaceAddress(currentPosition, context);
              },
            ),
            ///menu button
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: () {

                  scaffoldkey.currentState!.deactivate();
                  scaffoldkey.currentState!.activate();
                  scaffoldkey.currentState!.openDrawer();
/*                if (currentuserInfo != null) {

                } else {
                  Toast.showtoast(context, 'Connect to Internet first!');
                  return;
                }*/
                },
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: Colors.redAccent,
                    size: 10,
                  )
                ]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: SliderButton(
                              action: ()async {

                                if(!isOnline!){
                                  // add location to firebase
                                  GeoFirePoint myLocation = geo.point(latitude: 12.960632, longitude: 77.641603);
                                  var x= await _firestore
                                      .collection('tracking').doc(widget.user?.uid)
                                      .set({'name': 'random name', 'email':widget.user?.email,'position': myLocation.data,'status':'online'});
                                  getLocationUpdate();
                                  Fluttertoast.showToast(msg: 'You are now online', gravity: ToastGravity.TOP,fontSize: 15,backgroundColor: Colors.green, textColor: Colors.white);
                                  setState(() {
                                    isOnline=true;
                                  });

                                }else{
                                  //delete document from firestore
                                  if(documentid==''){
                                    await _firestore.collection('tracking').where('email',isEqualTo: widget.user?.email).get().then((value)async {
                                      if(value.docs.isNotEmpty){
                                        documentid=value.docs.first.id;
                                        await _firestore.collection('tracking').doc(documentid).update({'status':'offline'});
                                      }
                                    });
                                  }else{
                                    await _firestore.collection('tracking').doc(documentid).update({'status':'offline'});
                                  }

                                  Fluttertoast.showToast(msg: 'You are now offline',gravity: ToastGravity.TOP,fontSize: 15,backgroundColor: Colors.redAccent, textColor: Colors.white);
                                  setState(() {
                                    isOnline=false;
                                  });

                                }

                                await Future.error('zoon');

                              },

                              ///Put label over here
                              label: Text((!isOnline!)? "Slide to go online":"Slide to go offline",
                                style: const TextStyle(
                                    color:Color(0xff4a4a4a),
                                    fontWeight: FontWeight.w500,fontFamily: 'Brand-Bold',
                                    fontSize: 17),
                              ),
                              icon: const Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 40.0,
                                    semanticLabel:
                                    'Text to announce in accessibility modes',
                                  )),

                              ///Change All the color and size from here.
                              width: double.infinity,height: 50,
                              radius: 10,
                              buttonColor: (!isOnline!)? Colors.green:Colors.redAccent,
                              backgroundColor: BrandColors.colorLightGray,
                              highlightedColor: Colors.white,
                              baseColor: (!isOnline!)? Colors.green:Colors.redAccent,buttonSize: 50,dismissible: false,alignLabel: Alignment.center,  vibrationFlag: true,
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Note! Going online would enable all users you accepted to track your location",
                              style: TextStyle(
                                  fontSize:
                                  HelperMethods.getTextSize(textScale, 16),color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),


                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20.0,
              bottom: _fabHeight,
              child: FloatingActionButton.extended(  isExtended: false,
                backgroundColor: Colors.white,
                onPressed: _currentLocation,
                label: Text('My Location'),
                elevation: (expandedFab!) ? 0 : 6,
                icon: locationIcon,
              ),
            ),
          ]

      ),

    );


  }

  void getLocationUpdate()async {
    print('updating position 1');
    homeTabPositionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions)
            .listen((Position position)async{
          print('updating position');
          currentPosition = position;
          // update location if availability is true
          GeoFirePoint myLocation = geo.point(latitude: position.latitude, longitude: position.longitude);

          await _firestore
              .collection('tracking').doc(widget.user?.uid)
              .update({'position': myLocation.data});
          LatLng pose = LatLng(position.latitude, position.longitude);
          CameraPosition cp = new CameraPosition(target: pose, zoom: 14);
          mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

          await startTrack();
        });

  }

  Future<void> startTrack()async{
    print('the distance ${Provider.of<AppData>(context, listen: false).trackmeListDetailed?.length}');
    await Future.forEach(Provider.of<AppData>(context, listen: false).trackmeListDetailed!, (MyTrackUser element)async {
      num x= HelperMethods.calculateDistance(currentPosition!, element);
      print('the distance $x');
      //if distance meets up with fence
      if(x.toDouble()<=element.distance!.toDouble()){
        //send alarm notification to all users meeting this criteria
        await _firestore.collection('users').doc(element.tracker_id).get().then((value) {
          if(value.exists){
            sendPushNotification(value.get('token'), element.id!);
          }

        });
      }
    });

  }

  Future<void> sendPushNotification(String? token, String docid) async {
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      var response=  await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: constructFCMPayload(token, docid),
      );

      print('FCM request for device sent! ${response.body}');
    } catch (e) {
      print('send error $e');
    }
  }

  String constructFCMPayload(String? tokeen, String docid) {
    String? name =widget.user?.email?.split('@')[0];
    _messageCount++;
    String? body =
        'You are receiving this message because one of the persons you are tracking \" $name\", has just crossed into your boundaries and is close to you';
/*
    FirebaseFirestore.instance.collection('notifications').add({
      'sent_to': user?.id,
      'message': body,
      'time': DateTime.now().millisecondsSinceEpoch.toString(),
      'trackid': docid,
      'senderid': users?.uid,
      'read': false
    });
*/
    return jsonEncode({
      "notification": {
        "title": "Proximity Alarm",
        "body": body,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "icon": 'images/geoalarmlogo.png',
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        'via': 'FlutterFire Cloud Messaging!!!',
        'trackid': docid,
        'count': _messageCount.toString(),
        'status': 'done'
      },
      "to": "${token}"
    });
  }
  void getDocumentId()async{

    await _firestore.collection('tracking').where('email',isEqualTo: widget.user?.email).get().then((value)async {
      if(value.docs.isNotEmpty){
        documentid=value.docs.first.id;
        await _firestore.collection('tracking').doc(documentid).update({'status':'offline'});
      }
    });
  }
  Future<void> getMyTrack()async {
    EasyLoading.show(status: 'Loading...');
    Provider.of<AppData>(context,listen: false).myTrackedList?.clear();
    Provider.of<AppData>(context,listen: false).myTrackedListDetailed?.clear();
    MyTrackUser? myTrackedDetailed;
    List<MyTrackUser> myTrackedListDetailed=[];

    EasyLoading.dismiss();
    // update my track
    await _firestore.collection('mytrack').where('tracker_id',isEqualTo: widget.user?.uid).get().then((value)async{
      List<String>? mytrackedlist=[];
      if(value.docs.isNotEmpty){
        await Future.forEach(value.docs, (QueryDocumentSnapshot element)async{
          String id=element.id;

          mytrackedlist.add(id);
          await _firestore.collection('mytrack').doc(id).get().then((value) async{

            myTrackedDetailed = MyTrackUser.fromSnapshot(value);

            myTrackedListDetailed.add(myTrackedDetailed!);
          });
        });
        Provider.of<AppData>(context,listen: false).updateMyTrackedList(mytrackedlist);
        Provider.of<AppData>(context,listen: false).updateMyTrackedDetailedList(myTrackedListDetailed);


      }
    });

    // update tracking me


    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
    await getTrackme();
    await _firestore.collection('tracking').where('email',isEqualTo: widget.user?.email).get().then((value)async {
      if(value.docs.isNotEmpty){
        print(value.docs.first.data());
        checkStatus=value.docs.first.get('status');
        if(checkStatus=='online'){
          getLocationUpdate();
          setState(() {
            isOnline=true;
          });
        }
      }
    });
  }
  Future<void> getTrackme() async {

    Provider.of<AppData>(context, listen: false).myTrackedList?.clear();
    Provider.of<AppData>(context, listen: false).trackmeListDetailed?.clear();
    MyTrackUser? myTrackedDetailed;
    List<MyTrackUser> myTrackedListDetailed = [];
    await _firestore
        .collection('mytrack')
        .where('tracked_id', isEqualTo: widget.user?.uid).where('status',isEqualTo: 'accepted')
        .get()
        .then((value) async {
      List<String>? mytrackedlist = [];
      if (value.docs.isNotEmpty) {

        await Future.forEach(value.docs, (QueryDocumentSnapshot element) async {
          String id = element.id;
          mytrackedlist.add(id);
          await _firestore
              .collection('mytrack')
              .doc(id)
              .get()
              .then((value) async {
            myTrackedDetailed = MyTrackUser.fromSnapshot(value);
            myTrackedListDetailed.add(myTrackedDetailed!);
          });
        });
        Provider.of<AppData>(context, listen: false)
            .updateMyTrackedList(mytrackedlist);
        Provider.of<AppData>(context, listen: false)
            .updateTrackMeDetailedList(myTrackedListDetailed);
      }else{
        print('the dock is empty');
      }
    });

  }


}




