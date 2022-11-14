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

class MyTrackedScreen extends StatefulWidget {
  static const String id = 'mytrackedlist';
  const MyTrackedScreen({Key? key}) : super(key: key);

  @override
  _MyTrackedScreenState createState() => _MyTrackedScreenState();
}

class _MyTrackedScreenState extends State<MyTrackedScreen> {
  final _firestore = FirebaseFirestore.instance;
  MyTrackUser? myTrackedDetailed;
  List<MyTrackUser> myTrackedListDetailed = [];
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showSearch(
              context: context, delegate: CustomSearchDelegate(user));
          getMyTrack();
        },
        child: Icon(Icons.add),
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
                  "My Tracked List",
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
                      .myTrackedListDetailed!
                      .isNotEmpty)
                  ? ListView.builder(
                      itemCount: Provider.of<AppData>(context, listen: true)
                          .myTrackedListDetailed
                          ?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return trackedWidget(
                            user: Provider.of<AppData>(context, listen: true)
                                .myTrackedListDetailed![index],
                            theme: _theme);
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
                                  'You are not tracking any one, click the add button to search for people to track',
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
    Provider.of<AppData>(context, listen: false).myTrackedListDetailed?.clear();
    MyTrackUser? myTrackedDetailed;
    List<MyTrackUser> myTrackedListDetailed = [];
    await _firestore
        .collection('mytrack')
        .where('tracker_id', isEqualTo: user?.uid)
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
            .updateMyTrackedDetailedList(myTrackedListDetailed);
      }
    });
    EasyLoading.dismiss();
  }

  Widget trackedWidget({required MyTrackUser user, required ThemeData theme}) {
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
                      Icon(
                        Icons.location_on_outlined,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: Text("${user.placeName}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis)),
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${user.status!}',
                        style: TextStyle(
                            color: (user.status != 'pending')
                                ? Colors.green
                                : Colors.amber),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    height: 50,
                    color: Colors.black12,
                    width: 2,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  (user.status != 'pending')
                      ? Expanded(
                          child: IconsOutlineButton(
                            onPressed: () {},
                            text: 'Live Track',
                            iconData: Icons.cancel_outlined,
                            textStyle: TextStyle(color: Colors.blue),
                            iconColor: Colors.blue,
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: IconsButton(
                      onPressed: (){
                        _cancelTrack(user.id!);
                        getMyTrack();
                        Provider.of<AppData>(context,listen: false).deleteMyTrackedDetailedList(user);
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
