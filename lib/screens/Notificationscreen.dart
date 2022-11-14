import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'dart:async' show Timer;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import '../brand_colors.dart';
import '../globalvariables.dart';
import '../helpers/helpermethods.dart';
import '../models/notification.dart';
import '../providers/appdata.dart';
import '../widgets/notificationdialogue.dart';
import '../widgets/notitile.dart';

class NotificationPage extends StatefulWidget {
  static const String id = 'notification';
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isloading = false;
  bool isNotificationEmpty = true;
  User? user ;
  _NotificationPageState();
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    user = Provider.of<AppData>(context, listen: false).currentuserInfo;
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData _theme = Theme.of(context);
    final textScale = MediaQuery.of(context).size.height * 0.01;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: _theme.scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                (Platform.isIOS) ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body:
        SingleChildScrollView(
          child: Container(
            color: _theme.scaffoldBackgroundColor,
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Notifications",
                  style: _theme.textTheme.headline1?.merge(TextStyle(
                      fontSize: HelperMethods.getTextSize(textScale, 28),
                      fontFamily: "Brand-Bold",
                      color: Colors.black)),
                ),
                SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child:

                  RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: BrandColors.colorLightblue,
                      onRefresh: () {
                      return Future.error('smack');
                      },
                      child:
                      PaginateFirestore(separator: Divider(),
                        onEmpty:
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent:
                            AlwaysScrollableScrollPhysics()),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 300),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text(
                                  'NO EVENT',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                        itemBuilderType:
                      PaginateBuilderType.listView, //Change types accordingly
                        itemBuilder: (context, documentSnapshots, index) {
                          if (!documentSnapshots.isNotEmpty) {

                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                  parent:
                                  AlwaysScrollableScrollPhysics()),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 300),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'NO EVENT',
                                        style: TextStyle(
                                          fontSize: 25,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );

                          }
                          if(documentSnapshots.isNotEmpty){
                            isNotificationEmpty = false;
                          }else{
                            isNotificationEmpty = true;
                          }

                          final notification = documentSnapshots[index].data() as Map?;

                          final trackid = notification!['trackid'];
                          final message = notification['message'];
                          final read = notification['read'];
                          final time = notification['time'];
                          final senderId = notification['senderid'];
                          final notiId = documentSnapshots[index].id;



                          return notiWidget(Noti(
                              time: time,
                              trackid: trackid,
                              message: message,
                              read: read,
                              senderId: senderId,
                              notiId: notiId));

                        },
                        // orderBy is compulsory to enable pagination
                        query: _firestore
                            .collection('notifications')
                            .where('sent_to',isEqualTo: user?.uid).orderBy('time',descending: true),
                        itemsPerPage: 7,
                        // to fetch real-time data
                        isLive: true, physics: BouncingScrollPhysics(),  ),
                     )),

              ],
            ),
          ),
        ));
  }

  String getTime(String time) {
    final now = new DateTime.now();
    final difference =
        now.difference(DateTime.fromMillisecondsSinceEpoch(int.parse(time)));

    return timeago.format(now.subtract(difference), locale: 'en');
  }


  Widget notiWidget(Noti notification){
    return   TextButton(
        onPressed: () async {

          updateSeen(notification.notiId);
          if(notification.trackid!=null){
            await HelperMethods.fetchmyTrackInfo(notification.trackid!, context);
            if(currenttrackinfo!=null){
              showDialog(context: context,
                  barrierDismissible: false,
                  builder:(BuildContext context)=> NotificationDialogManual(currenttrackinfo!));
            }
          }

        },
        style: ButtonStyle(
          backgroundColor: ((notification.read))
              ? MaterialStateProperty.all<
              Color>(Colors.white)
              : MaterialStateProperty.all<
              Color>(
              BrandColors.colorSkyblue),
          foregroundColor:
          MaterialStateProperty.all<
              Color>(
            Colors.black87,
          ), //text (and icon)
        ),
        child: Stack(children: [
          (!notification.read)
              ? Icon(
            Icons.circle,
            color: BrandColors
                .colorLightblue,
            size: 15,
          )
              : SizedBox(),
          NotificationTile(
            notification: notification,
          )
        ]));

  }


  void updateSeen(String? id) {
    _firestore
        .collection('notifications')
        .doc(id)
        .update({'read': true});
  }

}
