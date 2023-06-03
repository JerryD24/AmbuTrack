import 'package:patient/driver/lib/global/global.dart';
import 'package:flutter/material.dart';
import 'package:patient/mainScreens/toggle_screen.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import '../splashScreen/driver_splash_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text("Sign Out"),
        onPressed: ()
        {
          Geofire.removeLocation(currentFirebaseUser!.uid);
          fAuth .signOut();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=> ToggleScreenPage()),(Route<dynamic> route) => false);
        },
      ),
    );
  }
}
