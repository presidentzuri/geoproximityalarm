import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoproxyalarm/models/trackmodel.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

import '../globalvariables.dart';

class AlarmDialogManual extends StatelessWidget {
  final MyTrackUser trackinfo;

  AlarmDialogManual(this.trackinfo);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30.0,
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/geoalarmlogo.png',
                  width: 50,
                )),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'PROXIMITY ALARM',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 13),
            ),
            SizedBox(
              height: 16.0,
            ),
            Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Text('Name:', style: const TextStyle(fontSize: 18)),
                    title: Text(
                      trackinfo.userName!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),minVerticalPadding: 0,
                  ),
                  ListTile(
                    leading: Text(
                      'Distance trigger:',
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(
                      '${trackinfo.distance!.toInt().toString()} meters',
                      style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    ),minVerticalPadding: 0,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  StaticMap(
                    googleApiKey: mapKey,
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    zoom: 15,
                    format: MapImageFormat.png8,
                    scaleToDevicePixelRatio: true,
                    center: Location(trackinfo.location!.latitude,
                        trackinfo.location!.longitude),
                    styles: <MapStyle>[
                      MapStyle(
                        element: StyleElement.geometry.fill,
                        feature: StyleFeature.all,
                        rules: <StyleRule>[
                          StyleRule.color(Colors.grey),
                        ],
                      ),
                      MapStyle(
                        feature: StyleFeature.water,
                        rules: <StyleRule>[
                          StyleRule.color(Colors.grey),
                          StyleRule.lightness(-30),
                        ],
                      )
                    ],
                    markers: <Marker>[
                      Marker(
                        color: Colors.lightBlue,
                        label: 'A',
                        locations: [
                          Location(trackinfo.location!.latitude,
                              trackinfo.location!.longitude),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       Icon(Icons.location_on_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(padding: EdgeInsets.all(8),
                          child: Text(
                            trackinfo.placeName!,
                            style: TextStyle(
                                fontSize: 14, overflow: TextOverflow.ellipsis),
                          ),
                          alignment: Alignment.center,
                        ))
                      ],
                    ),
                  ),

                ],
              ),
            ),

            Divider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: IconsOutlineButton(
                      onPressed: () {
                          Navigator.pop(context);
                      },
                      text: 'Close',
                      iconData: Icons.cancel_outlined,
                      textStyle: TextStyle(color: Colors.grey),
                      iconColor: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: IconsButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      text: 'Noted',
                      iconData: Icons.check,
                      color: Colors.green,
                      textStyle: TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }


  acceptFireStore(context) async {
    if(trackinfo.status == 'accepted'){
      Fluttertoast.showToast(
          msg: 'Request already accepted',
          textColor: Colors.white,
          backgroundColor: Colors.amber);
      return;
    }
    String orderId = trackinfo.id!;
    await FirebaseFirestore.instance
        .collection('mytrack')
        .doc(orderId)
        .get()
        .then((value) {
      if (!value.exists) {
        Fluttertoast.showToast(
            msg: 'Request no longer available',
            textColor: Colors.white,
            backgroundColor: Colors.redAccent);
        return;
      }
    });

    await FirebaseFirestore.instance.collection('mytrack').doc(orderId).update({
      'status': 'accepted','send_time':DateTime.now().millisecondsSinceEpoch.toString()
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(
          msg: 'Couldn\'t update details',
          textColor: Colors.white,
          backgroundColor: Colors.redAccent);
    });
    Navigator.pop(context);
  }
}
