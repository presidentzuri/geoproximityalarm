import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:geoproxyalarm/models/usermodels.dart';
import 'package:geoproxyalarm/screens/setlocationscreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:provider/provider.dart';
import '../brand_colors.dart';
import '../globalvariables.dart';
import '../providers/appdata.dart';

class CustomSearchDelegate extends SearchDelegate {
  User? users;
  int _messageCount = 0;
  CustomSearchDelegate(this.users);
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
              style: TextStyle(
                  color: BrandColors.colorDimText,
                  fontFamily: 'Brand-Bold',
                  fontSize: 20),
              textAlign: TextAlign.center,
            ),
          )
        ],
      );
    }
    //Add the search term to the searchBloc.
    //The Bloc will then handle the searching and add the results to the searchResults stream.
    //This is the equivalent of submitting the search term to whatever search service you are using

    return Column(
      children: <Widget>[
        //Build the results based on the searchResults stream in the searchBloc
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(10)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "No Results Found.",
                    ),
                  ],
                ),
              );
            } else {
              final users = snapshot.data?.docs.reversed;
              List<UserModel> trackUsers = [];

              users?.forEach((customer) {
                final name = customer.get('email').toString().split('@')[0];
                String? image = customer.get('image');
                final id = customer.id;
                final email = customer.get('email');
                final token = customer.get('token');
                trackUsers.add(UserModel(name, image, id, email, token));
              });

              return Container(
                height: MediaQuery.of(context).size.height * .71,
                child: ListView.builder(
                  itemCount: trackUsers.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {},
                        child: trackedWidget(
                            user: trackUsers[index],
                            theme: _theme,
                            context: context));
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget trackedWidget(
      {required UserModel user, required ThemeData theme, context}) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return Container(
      margin: EdgeInsets.only(
        top: 10.0,
      ),
      child: Card(
        elevation: 0.0,
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(
                    left: 0.0,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          toBeginningOfSentenceCase(user.name)!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text("${user.email}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis)),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                  trailing: Text('user'),
                  leading: (user.image == null)
                      ? CircleAvatar(
                          maxRadius: 30,
                          backgroundImage:
                              AssetImage('images/geoalarmlogo.png'),
                        )
                      : CircleAvatar(
                          maxRadius: 25,
                          backgroundImage: NetworkImage('${user.image}'),
                        )),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: IconsButton(
                      onPressed: () async {
                        String docid = '';
                        var x =
                            await Navigator.pushNamed(context, SelectMap.id);
                        if (x == 'done') {
                          print('it is done');
                          await _firestore.collection('mytrack').add({
                            'distance': selectedDistance,
                            'image': user.image,
                            'name': user.email?.split('@')[0],
                            "place": finalAddress,
                            "position": GeoPoint(currentPosition!.latitude,
                                currentPosition!.longitude),
                            "status": "pending",
                            "tracked_id": user.id,
                            "tracker_id": users?.uid,
                            "send_time":null
                          }).then((value) {
                            docid = value.id;
                          });
                          Fluttertoast.showToast(
                              msg: 'Sending request',
                              textColor: Colors.white,
                              backgroundColor: Colors.green,
                              gravity: ToastGravity.SNACKBAR);
                          if (docid == '') return;
                         await sendPushNotification(user, docid);
                          Fluttertoast.showToast(
                              msg: 'Request sent',
                              textColor: Colors.white,
                              backgroundColor: Colors.green,
                              gravity: ToastGravity.SNACKBAR);
                          // Fluttertoast.showToast(msg: 'Sending Request...',textColor: Colors.white,backgroundColor: Colors.green);

                        }
                        EasyLoading.dismiss();
                      },
                      text: 'Setup Track',
                      iconData: Icons.track_changes,
                      color: Colors.green,
                      textStyle: TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }

  Future<void> sendPushNotification(UserModel? user, String docid) async {
    if (user?.token == null) {
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
        body: constructFCMPayload(user, docid),
      );

      print('FCM request for device sent! ${response.body}');
    } catch (e) {
      print('send error $e');
    }
  }

  String constructFCMPayload(UserModel? user, String docid) {
    String? name = users?.email?.split('@')[0];
    _messageCount++;
    String? body =
        'You have a new tracking request from ${name}, Click to find out more.';
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
    print("user token${user!.token!}");
    return jsonEncode({
      "notification": {
        "title": "New Tracking Request",
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
      "to": "${user.token!}"
    });
  }
}
