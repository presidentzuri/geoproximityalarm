import 'package:flutter/material.dart';
import 'package:geoproxyalarm/screens/authpage.dart';

import '../main.dart';
import 'homepage.dart';


class FlashScreen extends StatefulWidget {
  static const String id = 'flashscreen';
  const FlashScreen({Key? key}) : super(key: key);

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(
          builder: (context) => AuthScreen()), (route) => false);
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final textScale=MediaQuery.of(context).size.height * 0.01;
    return Scaffold(backgroundColor: Colors.white,
      body: Container(color: Colors.white, child: Padding(
        padding: const EdgeInsets.only(top: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(borderRadius: BorderRadius.circular(20),
                child: const Image(
                  alignment: Alignment.center,
                  height: 250.0,
                  width: 250.0,
                  image: AssetImage('images/geoalarmlogo.png'),

                ),
              ),
            ),
            Text(
              'GEO PROXIMITY ALARM',
              style: TextStyle(color: Colors.amber, fontSize: 2*textScale,letterSpacing: 3.0,fontFamily: 'Brand-Bold'),
            )
          ],
        ),
      ),),
    );
  }/* build(BuildContext context) {
    final textScale=MediaQuery.of(context).size.height * 0.01;
    final screenHeight=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height:screenHeight* .1,),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  child: Column(

                    children: [
                      Container(
                        color: BrandColors.colorLightblue,
                        width: 250,
                        child: Stack(children: [
                          TextLiquidFill(
                            text: 'WOTA',
                            waveColor: Colors.white,
                            waveDuration: Duration(seconds: 3),
                            loadDuration: Duration(seconds: 4),
                            boxBackgroundColor: Colors.black,
                            textStyle: TextStyle(
                                fontSize: 7*textScale,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Brand-Bold'),
                            boxWidth: 270,
                            boxHeight: screenHeight*.2,
                          ),

                        ]),
                      ),
                    ],
                  ),
                ),
                Container(width: double.infinity,),
              ],
            ),
          ),
          Container(height: screenHeight*.15,),
          Text(
            'WORLD OF THIRST APP',
            style: TextStyle(color: Colors.blueGrey, fontSize: 1.3*textScale,letterSpacing: 3.0),
          )
        ],
      ),
    );
  }*/
}