// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, duplicate_ignore

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patient/authority/lib/authentication/login_screen.dart'
    as auth_login;
import 'package:patient/authority/lib/mainScreens/main_screen.dart'
    as authority_main_screen;
import 'package:patient/driver/lib/authentication/login_screen.dart'
    as driver_login;
import 'package:patient/driver/lib/mainScreens/main_screen.dart'
    as driver_main_screen;
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
  check(userType) async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child(userType)
        .child(fAuth.currentUser!.uid);
    DatabaseEvent snap = await userRef.once();
    if (snap.snapshot.value != null) {
      return snap.snapshot;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print(toggleIndex.toString() +
        "--------------------------------------------");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 80,
              ),
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Image.asset("images/hospital-logo.jpg"),
              ),
              const Text(
                "Every Sec Count For Us",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              ToggleSwitch(
                // minWidth: MediaQuery.of(context).size.width/3,
                minHeight: 70.0,
                minWidth: 90,
                initialLabelIndex: toggleIndex,
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
                // isVertical: true,
                dividerMargin: 0,
                // labels: [
                //   "Patient",
                //   "Ambulance",
                //   "Authority"
                // ],
                iconSize: 30.0,

                borderColor: [
                  Color(0xff3b5998),
                  Color(0xff8b9dc3),
                  Color(0xff00aeff),
                  Color(0xff0077f2),
                  Color(0xff962fbf),
                  Color(0xff4f5bd5)
                ],
                dividerColor: Colors.blueGrey,
                activeBgColors: [
                  [Color(0xff3b5998), Color(0xff8b9dc3)],
                  [Color(0xff00aeff), Color(0xff0077f2)],
                  [
                    Color(0xfffeda75),
                    Color(0xfffa7e1e),
                    Color(0xffd62976),
                    Color(0xff962fbf),
                    Color(0xff4f5bd5)
                  ]
                ],
                onToggle: (index) {
                  toggleIndex = index!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (toggleIndex == 0) {
                    var x = fAuth.currentUser != null
                        ? await AssistantMethods.readCurrentOnlineUserInfo()
                        : null;
                    if (x != null) {
                      currentFirebaseUser = fAuth.currentUser;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (c) => MainScreen()),
                          (Route<dynamic> route) => false);
                    } else {
                      fAuth.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => LoginScreen()));
                    }
                  }
                  if (toggleIndex == 1) {
                    var x = fAuth.currentUser != null
                        ? await check("Drivers")
                        : null;
                    if (x != null) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (c) => driver_main_screen.MainScreen()),
                          (Route<dynamic> route) => false);
                    } else {
                      fAuth.signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => driver_login.LoginScreen()));
                    }
                    // Navigator.push(context, MaterialPageRoute(builder: (c)=>  DriverSplashScreen()));
                    Fluttertoast.showToast(msg: " You have selected as Driver");
                  }
                  if (toggleIndex == 2) {
                    var x = fAuth.currentUser != null
                        ? await check("Authority")
                        : null;
                    if (x != null) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  authority_main_screen.MainScreen()),
                          (Route<dynamic> route) => false);
                    } else {
                      fAuth.signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => auth_login.LoginScreen()));
                    }
                    Fluttertoast.showToast(
                        msg: " You have selected as Authority");
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    fixedSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                child: const Text("Proceed",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueGrey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
