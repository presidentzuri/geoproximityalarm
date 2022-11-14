import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart' hide LocationAccuracy;
import 'package:map_picker/map_picker.dart';


import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../brand_colors.dart';
import '../globalvariables.dart';
import '../helpers/helpermethods.dart';
import '../providers/appdata.dart';


const kMarkerId = MarkerId('MarkerId1');
const kDuration = Duration(seconds: 2);

class SelectMap extends StatefulWidget {
  static const String id = 'selectmap';

  SelectMap();
  @override
  _SelectMapState createState() => _SelectMapState();
}

class _SelectMapState extends State<SelectMap> with TickerProviderStateMixin {
  double mapBottomPadding = 0;
  double fabAlign = 1;

  double requestingsheetHeight = 0; //(Platform.isAndroid)? 195:220;
  double detailssheetHeight = 0; //platform.isandroid ? 275:300

  LatLng? newProbePosition;
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  MapPickerController mapPickerController = MapPickerController();
  var textController = TextEditingController();
  Set<Circle> _circles = Set<Circle>();
  Circle? radiusCircle;
  //set threshold to 100 meters
  double _sliderValue = 0.1;
  double subMax = 0.1;
  late LatLng pose;
  final markersonly = <MarkerId, Marker>{};

  @override
  void initState() {
    _currentLocation();
    // TODO: implement initState
    super.initState();
  }

  var locationOptions =
  LocationSettings(accuracy: LocationAccuracy.bestForNavigation);

  Icon locationIcon = Icon(
    Icons.location_disabled_rounded,
    color: Colors.black26,
  );

  void _currentLocation() async {
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
  }

  CameraPosition cameraPosition = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 25.151926040649414);
  Future<void> setupPositionLocator() async {
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
    setState(() {
      locationIcon = Icon(
        Icons.my_location,
        color: Colors.black45,
      );
    });
/*
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    // SET CURRENT POSITION;
    currentPosition = position;
    LatLng pose = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pose, zoom: 17);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));*/
  }

  bool nearbyProbesKeyLoaded = false;

  LatLng customLatLng() {
    //this return selected place lat lng
    //or current position latlng
    var order = Provider.of<AppData>(context, listen: false).deliveryAddress;

    if (Provider.of<AppData>(context, listen: false).deliveryAddress == null) {
      return LatLng(currentPosition!.latitude, currentPosition!.longitude);
    } else {
      return LatLng(order!.latitude, order.longitude);
    }
  }

  //var stream = Stream.periodic(kDuration, (count) => FireHelper.nearbyProbesList[count]).take(FireHelper.nearbyProbesList.length);
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.height * 0.01;
    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment(1, 0.35),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          onPressed: _currentLocation,
          label: Text(
            'My Location',
            style: TextStyle(color: Colors.black),
          ),
          icon: locationIcon,
        ),
      ),
      key: scaffoldkey,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          MapPicker(
            // pass icon widget
            iconWidget: Icon(
              Icons.add_location_rounded,color: BrandColors.colorLightblue,
              size: 50,
            ),
            //add map picker controller
            mapPickerController: mapPickerController,
            child: GoogleMap(
              myLocationEnabled: true,compassEnabled: false,
              zoomControlsEnabled: false,circles: _circles,
              // hide location button
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              //  camera position
              initialCameraPosition: cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMoveStarted: () {
                // notify map is moving
                mapPickerController.mapMoving!();
                textController.text = "checking ...";
              },
              onCameraMove: (cameraPosition) {
                this.cameraPosition = cameraPosition;
              },
              onCameraIdle: () async {

                // notify map stopped moving
                mapPickerController.mapFinishedMoving!();
                //get address name from camera position
                Position position = Position(
                    latitude: cameraPosition.target.latitude,
                    longitude: cameraPosition.target.longitude,
                    floor: 1,
                    heading: 0.0,
                    accuracy: 0,
                    timestamp: DateTime.now(),
                    altitude: 0,
                    speed: 0,
                    speedAccuracy: 0);
                currentPosition=position;
                finalAddress = await HelperMethods.findCoordinateAddress(
                    position, context);
                // update the ui with the address
                /*   await HelperMethods.findCoordinateAddress(position, context);*/
                setupPositionLocator();

                setState(() {
                  textController.text = finalAddress!;
                  pose = LatLng(position.latitude, position.longitude);
                  radiusCircle = Circle(
                    circleId: const CircleId('radius'),
                    strokeColor: Colors.blue,
                    strokeWidth: 3,
                    radius: (1000 * _sliderValue).toDouble(),
                    center: pose,
                  );
                  _circles.removeWhere((element) => element.mapsId.value == 'radius');
                  _circles.add(radiusCircle!);
                });
              },
            ),
          ),
          ///menu button
          Positioned(
            top: 44,left: 20,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context,'notdone');
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7,0.7)
                      )
                    ]
                ),
                child:  CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child:Icon(Icons.clear,color: Colors.black,),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight:Radius.circular(20),topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7)
                    )
                  ]
              ),
              height: MediaQuery.of(context).size.height*.30,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 2,child: Text(textController.text, style: TextStyle(fontSize: HelperMethods.getTextSize(textScale, 18),fontFamily: 'Brand-Bold'),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,maxLines: 3,)),
                    Expanded(flex: 4,
                      child: Container(
                        child: Center(
                          child: SfSlider(
                            value: _sliderValue,
                            min: .5,
                            max: 7,
                            showLabels: true,
                            showTicks: true,
                            shouldAlwaysShowTooltip: true,
                            tooltipShape: SfPaddleTooltipShape(),
                            activeColor: Colors.amber,
                            minorTicksPerInterval: 1,
                            tooltipTextFormatterCallback:
                                (dynamic actualValue,
                                String formattedText) {
                              return ' $formattedText Km';
                            },
                            showDividers: true,
                            interval: .5,
                            onChanged: (value) async {

                              if (value >= 0.1) {
                                setState(() {
                                  _sliderValue = value;
                                });

                                setState(() {
                                  radiusCircle = Circle(
                                    circleId: const CircleId('radius'),
                                    strokeColor:
                                    Colors.amber,
                                    strokeWidth: 3,
                                    radius: (1000 * _sliderValue)
                                        .toDouble(),
                                    center: pose,
                                  );

                                  _circles.removeWhere((element) =>
                                  element.mapsId.value == 'radius');
                                  _circles.add(radiusCircle!);
                                });
                              } else {
                                Fluttertoast.showToast(msg: 'Minimum radius is 100 meters');

                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Expanded(flex: 3,
                      child: SizedBox(
                        height:40,width: MediaQuery.of(context).size.width*.7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: const Text(
                              "Select",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                color: Color(0xFFFFFFFF),
                                fontSize: 19,
                                // height: 19/19,
                              ),
                            ),
                            onPressed: () {
                              selectedDistance=_sliderValue*1000;
                              Navigator.pop(context,'done');

                              /* print(
                                    "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
                                print("Address: ${textController.text}");*/
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  BrandColors.colorLightblue),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
