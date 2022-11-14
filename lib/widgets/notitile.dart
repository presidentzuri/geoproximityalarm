

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async' show Timer;

import '../helpers/helpermethods.dart';
import '../models/notification.dart';


class NotificationTile extends StatelessWidget {

  final Noti notification;
  NotificationTile({required this.notification});

  var locale = 'en';
  String getTime () {
    final now = new DateTime.now();
    final difference = now.difference(DateTime.fromMillisecondsSinceEpoch(int.parse(notification.time)));

    return timeago.format(now.subtract(difference), locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                child: Row(
                  children: <Widget>[

                    SizedBox(width: 18,),
                    Expanded(child: Container(child: Text(notification.message, overflow: TextOverflow.visible, style: TextStyle(fontSize: 15),))),
                    SizedBox(width: 5,),
                  ],
                ),
              ),

              SizedBox(height: 15,),

              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('${HelperMethods.formatMyDate(DateTime.fromMillisecondsSinceEpoch(int.parse(notification.time)).toString())}',
                  style: TextStyle(fontFamily: '', fontSize: 12, color: Colors.black45),),
              ),
            ],
          ),


        ],
      ),
    );
  }

}
