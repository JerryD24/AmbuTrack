import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patient/driver/lib/splashScreen/driver_splash_screen.dart';
import 'package:patient/authority/lib/splashScreen/authority_splash_screen.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../assistants/assistant_methods.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';
import 'main_screen.dart';

class ToggleScreenPage extends StatefulWidget {
  const ToggleScreenPage({Key? key}) : super(key: key);

  @override
  State<ToggleScreenPage> createState() => _ToggleScreenPageState();
}

class _ToggleScreenPageState extends State<ToggleScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToggleSwitch(
              minWidth: 90.0,
              minHeight: 70.0,
              initialLabelIndex: 0,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 3,
              icons: [
                FontAwesomeIcons.user,
                FontAwesomeIcons.ambulance,
                FontAwesomeIcons.university
              ],
              iconSize: 30.0,

              borderColor: [Color(0xff3b5998), Color(0xff8b9dc3), Color(0xff00aeff), Color(0xff0077f2), Color(0xff962fbf), Color(0xff4f5bd5)],
              dividerColor: Colors.blueGrey,
              activeBgColors: [[Color(0xff3b5998), Color(0xff8b9dc3)], [Color(0xff00aeff), Color(0xff0077f2)], [Color(0xfffeda75), Color(0xfffa7e1e), Color(0xffd62976), Color(0xff962fbf), Color(0xff4f5bd5)]],
              onToggle: (index) {
                toggleIndex=index!;
              },
            ),

            const SizedBox(height: 20,),



            ElevatedButton(
              onPressed: (){
              if(toggleIndex == 0)
                {
                    fAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
                      if(fAuth.currentUser != null)
                        {
                          currentFirebaseUser = fAuth.currentUser;
                          Navigator.push(context, MaterialPageRoute(builder: (c)=>  MainScreen()));
                        }
                      else
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                        }
                }
              if(toggleIndex==1)
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>  DriverSplashScreen()));
                  Fluttertoast.showToast(msg: " You have selected as Driver");
                }
              if(toggleIndex==2)
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>  AuthoritySplashScreen()));
                  Fluttertoast.showToast(msg: " You have selected as Authority");
                }
            },

              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  fixedSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              child: const Text("Select",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blueGrey)),

            )
          ],
        ),
      ),
    );
  }
}
