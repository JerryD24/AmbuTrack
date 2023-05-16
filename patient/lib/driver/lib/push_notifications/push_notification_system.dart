import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:patient/driver/lib/global/global.dart';
import 'package:patient/driver/lib/models/patientRideRequestInformation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  Future initializeCloudMessaging(BuildContext context) async
  {
    //1. Terminated
    //when the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null)
        {
          //display the ride request information  - Patient information who actually book Ambulance

          readPatientRideRequestInformation(remoteMessage.data["rideRequestId"],context);
          print("This is Ride Request Id");
          print(remoteMessage.data["rideRequestId"]);
          
        }
    });



    //2. Foreground
    //When the app is open and it receive the notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage)
    {

      readPatientRideRequestInformation(remoteMessage?.data["rideRequestId"],context);
      print("This is Ride Request Id");
      print(remoteMessage!.data["rideRequestId"]);
    });


    //3. Background
    //When the app is in the background and opened from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage)
    {
      readPatientRideRequestInformation(remoteMessage?.data["rideRequestId"],context);

    });
  }


  readPatientRideRequestInformation(String patientRideRequestId,BuildContext context)
  {
    FirebaseDatabase.instance.ref()
        .child("Ambulance Request")
        .child(patientRideRequestId)
        .once()
        .then((snapData)
    {
      if(snapData.snapshot.value != null)
        {
          audioPlayer.open(Audio("music/music-notification.mp3"));
          audioPlayer.play();

          double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
          double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
          String originAddress =(snapData.snapshot.value! as Map)["originAddress"].toString();

          // double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
          // double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
          // String destinationAddress =(snapData.snapshot.value! as Map)["destinationAddress"].toString();

          String userName =(snapData.snapshot.value! as Map)["userName"].toString();
          String userPhone =(snapData.snapshot.value! as Map)["userPhone"].toString();

          String? rideRequestId= snapData.snapshot.key;

          PatientRideRequestInformation patientRideRequestDetails =PatientRideRequestInformation();

          patientRideRequestDetails.originLatLng = LatLng(originLat, originLng);
          patientRideRequestDetails.originAddress = originAddress;

          // patientRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
          // patientRideRequestDetails.destinationAddress = destinationAddress;

          patientRideRequestDetails.userName = userName;
          patientRideRequestDetails.userPhone = userPhone;

          patientRideRequestDetails.rideRequestId = rideRequestId;

          showDialog(
            context: context,
            builder: (BuildContext context) => NotificationDialogBox(
              patientRideRequestDetails: patientRideRequestDetails,
            ),
          );


        }
      else
        {
          Fluttertoast.showToast(msg: "This ambulance request id do not exist.");
        }
    });

  }

  Future generateAndGetToken() async
  {
    String? registrationToken = await messaging.getToken();
    // print("FCM Registration Token");
    // print(registrationToken);

    await FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    await messaging.subscribeToTopic("Ambulance Driver");
    await messaging.subscribeToTopic("Ambulance Patient");
  }
}