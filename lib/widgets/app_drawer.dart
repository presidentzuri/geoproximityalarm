import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoproxyalarm/screens/Notificationscreen.dart';
import 'package:geoproxyalarm/screens/mytracklist.dart';
import 'package:geoproxyalarm/screens/trackingme.dart';
import 'package:line_icons/line_icons.dart';

import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'package:provider/provider.dart';

import '../styles/styles.dart';


class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
 int? unreadNotification=0;
 var firestore = FirebaseFirestore.instance;
 StreamSubscription <QuerySnapshot<Map<String, dynamic>>>? notiSub;
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      width:300,
      color: Colors.white,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              color: Colors.white,
              height: 160,
              child: DrawerHeader(decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    CircleAvatar(maxRadius: 25,backgroundImage: AssetImage('images/geoalarmlogo.png') ,),
                    SizedBox(width: 30,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text((toBeginningOfSentenceCase(('test name'))!.split(' ')[0]==null)?'Loading':
                        toBeginningOfSentenceCase(('test name'))!.split(' ')[0],
                          style: TextStyle(fontSize: 20,fontFamily: 'Brand-Bold'),),
                        SizedBox(height: 5,),
                        GestureDetector(
                          onTap: (){
                          //  Navigator.of(context).pushNamed(ProfileRoute);
                          },
                            child:
                        Text('View Profile',style: TextStyle(color: Colors.lightBlue),)),
                      ],
                    ),
                    SizedBox(width:60,),

                  ],
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {


               // Navigator.of(context).pushNamed(GiftRoute);
              },
              child: ListTile(
                leading: Icon(LineIcons.gifts),
                title: Text('Free Gifts',style: kDrawerItemStyle,),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, TrackMeScreen.id);

              },
              child: ListTile(
                leading: Icon(LineIcons.sitemap),
                title: Text('Tracking me list',style: kDrawerItemStyle,),
              ),
            ),
            GestureDetector(
              onTap: () {
            Navigator.pushNamed(context, MyTrackedScreen.id);

              },
              child: ListTile(
                leading: Icon(LineIcons.mapMarked,color:Colors.orangeAccent,),
                title: Text('My tracked list',style: kDrawerItemStyle,),
              ),
            ),
            GestureDetector(
              onTap: ()async{
                Navigator.pushNamed(context, NotificationPage.id);
              },
              child: ListTile(
                leading: Icon(LineIcons.bell),
                title: Text('Notificatons',style: kDrawerItemStyle,),
              ),
            ),

            GestureDetector(
              onTap: ()async{

              },
              child: ListTile(
                leading: Icon(LineIcons.info),
                title: Text('About',style: kDrawerItemStyle,),
              ),
            ),


          ],
        ),
      ),
    );

  }

}
