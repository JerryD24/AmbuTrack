
// ignore_for_file: prefer_const_constructors

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:patient/driver/lib/assistants/assistant_methods.dart';
import 'package:patient/driver/lib/mainScreens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../models/patientRideRequestInformation.dart';



class NotificationDialogBox extends StatefulWidget
{
  PatientRideRequestInformation? patientRideRequestDetails;

  NotificationDialogBox({this.patientRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox>
{
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
              "images/driver_logo.png",
              width: 160,
            ),

            const SizedBox(height: 10,),

            //title
            const Text(
              "New Ride Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.grey
              ),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                        width: MediaQuery.of(context).size.width*3/5,
                        child: Text(
                          "Patient Address",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                  //origin location with icon
                  Row(
                    children: [
                      // Image.asset(
                      //   "images/origin.png",
                      //   width: 30,
                      //   height: 30,
                      // ),
                      const SizedBox(width: 14,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*3/5,
                        child: Text(
                          widget.patientRideRequestDetails!.originAddress!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 15.0),

                  // //destination location with icon
                  // Row(
                  //   children: [
                  //     // Image.asset(
                  //     //   "images/destination.png",
                  //     //   width: 30,
                  //     //   height: 30,
                  //     // ),
                  //     const SizedBox(width: 14,),
                  //     SizedBox(
                  //       width: MediaQuery.of(context).size.width*3/5,
                  //       child: Text(
                  //         widget.patientRideRequestDetails!.destinationAddress!,
                  //         style: const TextStyle(
                  //           fontSize: 16,
                  //           color: Colors.grey,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),


            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //cancel the rideRequest
                      FirebaseDatabase.instance.ref("Ambulance Request")
                          .child(widget.patientRideRequestDetails!.rideRequestId!)
                          .remove().then((value) =>
                      {
                        FirebaseDatabase.instance.ref()
                            .child("Drivers")
                            .child(currentFirebaseUser!.uid)
                            .child("newRideStatus").set("idle")
                      }).then((value) => {
                        FirebaseDatabase.instance.ref()
                            .child("Drivers")
                            .child(currentFirebaseUser!.uid)
                          .child("tripsHistory")
                          .child(widget.patientRideRequestDetails!.rideRequestId!).remove()
                      }).then((value) => {
                        Fluttertoast.showToast(msg: "Ambulance Request has been cancelled, Successfully.Restart app Now.")
                      });

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //accept the rideRequest
                      acceptRideRequest(context);
                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  acceptRideRequest(BuildContext context)
  {
    String getRideRequestId="";
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
        {
          getRideRequestId = snap.snapshot.value.toString();
        }
      else
        {
          Fluttertoast.showToast(msg: "This ride request does not exist.");
        }

      if(getRideRequestId == widget.patientRideRequestDetails!.rideRequestId)
      {
        FirebaseDatabase.instance.ref()
            .child("Drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");
        AssistantMethods.pauseLiveLocationUpdates();
        //send the driver to new Ride Screen
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => NewTripScreen(patientRideRequestDetails: widget.patientRideRequestDetails)),(Route<dynamic> route) => false);
      }
      else
      {
        Fluttertoast.showToast(msg: "Patient deleted the Ambulance Request.");
      }
    });
  }
}
