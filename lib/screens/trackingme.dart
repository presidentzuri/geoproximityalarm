import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoproxyalarm/brand_colors.dart';
import 'package:geoproxyalarm/widgets/deligate.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import '../helpers/helpermethods.dart';
import '../models/trackmodel.dart';
import '../providers/appdata.dart';

class TrackMeScreen extends StatefulWidget {
  static const String id = 'trackingme';
  const TrackMeScreen({Key? key}) : super(key: key);

  @override
  _TrackMeScreenState createState() => _TrackMeScreenState();
}

class _TrackMeScreenState extends State<TrackMeScreen> {
  final _firestore = FirebaseFirestore.instance;
  MyTrackUser? myTrackedDetailed;
  List<MyTrackUser> myTrackedListDetailed = [];
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyTrack();
    user = Provider.of<AppData>(context, listen: false).currentuserInfo;
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.height * 0.01;
    final screenHeight = MediaQuery.of(context).size.height;

    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),

      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tracking Me List",
                  style: _theme.textTheme.headline1?.merge(TextStyle(
                      fontSize: getTextSize(textScale, 26),
                      fontFamily: "Brand-Bold",
                      color: Colors.black)),
                ),
              ],
            ),
            SizedBox(
              height: getHeight(screenHeight, 30),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .78,
              child: (Provider.of<AppData>(context, listen: true)
                  .trackmeListDetailed!
                  .isNotEmpty)
                  ? ListView.builder(
                  itemCount: Provider.of<AppData>(context, listen: true)
                      .trackmeListDetailed
                      ?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return trackedWidget(
                        user: Provider.of<AppData>(context, listen: true)
                            .trackmeListDetailed![index],
                        theme: _theme,textScale: textScale);
                  })
                  : SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * .78,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.track_changes_outlined,
                          size: 50,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No one is tracking you',
                            style: TextStyle(
                                fontSize: HelperMethods.getTextSize(
                                    textScale, 20)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getHeight(double sysVar, double size) {
    double calc = size / 1000;
    return sysVar * calc;
  }

  double getTextSize(double sysVar, double size) {
    double calc = size / 10;
    return sysVar * calc;
  }

  Future<void> getMyTrack() async {
    EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    Provider.of<AppData>(context, listen: false).myTrackedList?.clear();
    Provider.of<AppData>(context, listen: false).trackmeListDetailed?.clear();
    MyTrackUser? myTrackedDetailed;
    List<MyTrackUser> myTrackedListDetailed = [];
    await _firestore
        .collection('mytrack')
        .where('tracked_id', isEqualTo: user?.uid).where('status',isEqualTo: 'accepted')
        .get()
        .then((value) async {
      List<String>? mytrackedlist = [];
      if (value.docs.isNotEmpty) {
        print('the dock aint empty');
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
    EasyLoading.dismiss();
  }

  Widget trackedWidget({required MyTrackUser user, required ThemeData theme, required double textScale}) {
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
                          toBeginningOfSentenceCase(user.userName)!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: getTextSize(textScale, 22)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: Text("${user.placeName}",
                            style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis, fontSize: getTextSize(textScale, 18  ))),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(user.distance!.toStringAsFixed(2)),
                      Text(
                        'meters',
                        style: TextStyle(color: BrandColors.colorDimText),
                      ),
                    ],
                  ),
                  leading: (user.imgUrl == null)
                      ? CircleAvatar(
                    maxRadius: 30,
                    backgroundImage:
                    AssetImage('images/geoalarmlogo.png'),
                  )
                      : CircleAvatar(
                    maxRadius: 25,
                    backgroundImage: NetworkImage('${user.imgUrl}'),
                  )),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: IconsButton(
                      onPressed: (){
                        _cancelTrack(user.id!);
                        getMyTrack();
                        Provider.of<AppData>(context,listen: false).deleteTrackMeDetailedList(user);
                      },
                      text: 'Cancel Track',
                      iconData: Icons.cancel_outlined,
                      color: Colors.redAccent,
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

  Future<void> _cancelTrack(String id) async {

    _firestore.collection('mytrack').doc(id).delete().whenComplete(
            (){ Fluttertoast.showToast(msg: 'Tracking cancelled sucessfully',textColor: Colors.white,gravity: ToastGravity.TOP);});
  }
}
