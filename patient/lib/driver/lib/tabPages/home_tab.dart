// ignore_for_file: unused_import
import 'dart:async';
import 'package:patient/driver/lib/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/black_theme_google_map.dart';
import '../global/global.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
{
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.3850, 78.4867),  //initial camera position is hyderabad
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText ="Now Online";
  Color buttonColor = Colors.grey;
  bool isDriverActive = true ;

  checkIfLocationPermissionAllowed()
  async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }
    return;
  }

  locateDriverPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);
    // print("This is your address = $humanReadableAddress");
  }

  readCurrentDriverInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap)
    {


      if(snap.snapshot.value != null)
        {
          onlineDriverData.id = (snap.snapshot.value as Map)["id"];
          onlineDriverData.name = (snap.snapshot.value as Map)["name"];
          onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
          onlineDriverData.email = (snap.snapshot.value as Map)["email"];

          onlineDriverData.ambulanceNumber = (snap.snapshot.value as Map)["ambulance_details"]["Ambulance-number"];
          onlineDriverData.hospitalName = (snap.snapshot.value as Map)["ambulance_details"]["Hospital-name"];

        }


    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed().then((permission){
      readCurrentDriverInformation();
      driverIsOnlineNow();
      updateDriversLocationAtRealTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController =controller;
    
            //for Black theme Google Map
            // blackThemedGoogleMap(newGoogleMapController);
    
            locateDriverPosition();
          },
        ),
    
        // ui for  online -offline drivers
        statusText != "Now Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        )
            :Container(),
    
        //button for online-offline
        // Positioned(
        //     top: statusText != "Now Online"
        //         ? MediaQuery.of(context).size.height *0.5
        //         : 25,
        //   left: 0,
        //   right: 0,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       ElevatedButton(
        //           onPressed: ()
        //           {
        //             if(isDriverActive != true) //in case of driver is offline
        //               {
        //               driverIsOnlineNow();
        //               updateDriversLocationAtRealTime();
    
        //               setState(() {
        //                 statusText = "Now Online";
        //                 isDriverActive = true;
        //                 buttonColor = Colors.transparent;
        //               });
    
        //               //display Toast
        //               Fluttertoast.showToast(msg: "You are Online Now");
        //             }
        //             // else //online
        //             //   {
        //             //     driverIsOfflineNow();
        //             //     setState(() {
        //             //       statusText = "Now Offline";
        //             //       isDriverActive = false;
        //             //       buttonColor = Colors.grey;
        //             //     });
    
        //             //     //display Toast
        //             //     Fluttertoast.showToast(msg: "You are Offline Now");
        //             //   }
        //           },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: buttonColor,
        //           padding: const EdgeInsets.symmetric(horizontal: 18,),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(26),
        //           ),
        //         ),
    
        //           child: statusText != "Now Online"
        //               ? Text(
        //             statusText,
        //             style: TextStyle(
        //               fontSize: 16,
        //               fontWeight: FontWeight.bold,
        //               color: Colors.white,
        //             ),
        //           )
        //               : const Icon(
        //             Icons.phonelink_ring,
        //             color: Colors.white,
        //             size: 26,
        //           ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
  
  driverIsOnlineNow() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );
    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.set("idle"); //searching for ambulance request
    ref.onValue.listen((event) { });
  }

  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position)
    {
       driverCurrentPosition = position;

       if(isDriverActive == true && fAuth.currentUser!=null)
        {
          Geofire.setLocation(
              currentFirebaseUser!.uid,
              driverCurrentPosition!.latitude,
              driverCurrentPosition!.longitude
          );
        }
        else {
         isDriverActive = false;
       }
       LatLng latLng = LatLng(
           driverCurrentPosition!.latitude,
           driverCurrentPosition!.longitude,
       );
       newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });

    // streamSubscriptionPosition?.cancel();
  }

  driverIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000),()
    {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
