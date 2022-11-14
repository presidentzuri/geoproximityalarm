import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoproxyalarm/providers/appdata.dart';
import 'package:geoproxyalarm/screens/homepage.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';


class AuthScreen extends StatelessWidget {
  static const String id = 'authpage';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        builder: (context, snapshot) {
          User? user;

          if (!snapshot.hasData) {
            user = snapshot.data;
            return SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: SignInScreen(
                    providerConfigs: const [
                      EmailProviderConfiguration(),
                      GoogleProviderConfiguration(
                          clientId:
                          '156575305688-5i9ddf20lc3a2vk481j6e4f2upk2mqee.apps.googleusercontent.com')
                    ],
                    headerBuilder: (context, constraints, _) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const Image(
                              alignment: Alignment.center,
                              height: 100.0,
                              width: 100.0,
                              image: AssetImage('images/geoalarmlogo.png'),
                            ),
                          ),
                        ],
                      );
                    },
                    subtitleBuilder: (context, action) {
                      return Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, right: 8),
                          child: Text(action == AuthAction.signIn
                              ? ' Sign In to use the buyers app'
                              : 'Sign Up to use the buyers app'));
                    },
                    footerBuilder: (context, action) {

                      return  Padding(
                          padding:const EdgeInsets.only(top: 10),
                          child:

                          Row(
                            children: [
                              Checkbox(value: true, onChanged: (bool? value){
                                /* setState(() {

                                    checked=value!;
                                    print(value);
                                  });*/
                              }),
                              Expanded(
                                child: GestureDetector(onTap: (){},
                                  child: RichText(
                                    text: TextSpan(
                                      // Note: Styles for TextSpans must be explicitly defined.
                                      // Child text spans will inherit styles from parent
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,fontFamily: 'Brand-Regular'
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(text:(action != AuthAction.signUp)? 'By signing in, you agree to our ': 'By signing up, you agree to our '),
                                        TextSpan(text: 'terms and conditions', style: TextStyle(fontFamily: 'Brand-Bold',color: BrandColors.colorLightblue)),
                                        TextSpan(text:(' and' )),
                                        TextSpan(text: ' privacy policy.', style: new TextStyle(fontFamily: 'Brand-Bold',color: BrandColors.colorLightblue),),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            user = snapshot.data;

            VerifyUser(context, user!);
            return Center(
              child: Container(
                margin: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),LoadingIndicator(size: 90, borderWidth: 5, color: Colors.amber),

                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Please wait....',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
        stream: FirebaseAuth.instance.authStateChanges(),
      ),
    );
  }

  Future<void> VerifyUser(context, User? user) async {
    print('the user is $user');
    if(user==null){

      return;
    }



    FirebaseFirestore _firestore=FirebaseFirestore.instance;
    _firestore.collection('users').where('id',isEqualTo: user.uid).get().then((value) {
      if(value.docs.isNotEmpty){
        Provider.of<AppData>(context,listen: false).updateCurrentUserInfo(user);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MyHomePage(title: 'Geoproxy alarm',user: user,),
                settings: RouteSettings(name: 'HomeScreen')),
                (route) => false);
      }else{
        _firestore.collection('users').doc(user.uid).set({'id':user.uid,'email':user.email,'image':user.photoURL});

    }

    });


    return ;
  }
}
