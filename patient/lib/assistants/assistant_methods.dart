import 'dart:convert';
// import 'dart:js';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patient/assistants/request_assistant.dart';
import 'package:patient/global/global.dart';
import 'package:patient/models/direction_details_info.dart';
import 'package:patient/models/directions.dart';
import 'package:patient/models/user_model.dart';
import 'package:provider/provider.dart';

import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import 'package:http/http.dart' as http;


class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";


    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error occurred,Failed.No response")
      {
        humanReadableAddress = requestResponse["results"][0]["formatted_address"];

        Directions patientPickUpAddress = Directions();

        patientPickUpAddress.locationLatitude = position.latitude;
        patientPickUpAddress.locationLongitude = position.longitude;
        patientPickUpAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(patientPickUpAddress);
      }
    return humanReadableAddress;
  }

  static readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("Patients")
        .child(currentFirebaseUser!.uid);

    DatabaseEvent snap = await userRef.once();
      if(snap.snapshot.value != null)
      {
        return userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
      return null;
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlobtainOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await  RequestAssistant.receiveRequest(urlobtainOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error occurred,Failed.No response")
      {
        return null;
      }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String patientRideRequestId, context) async
  {
    String dropOffLocationAddress = patientDropOffLocation;

    Map<String, String> headerNotification =
        {
          'Content-Type' : 'application/json',
          'Authorization' : cloudMessagingServerToken,
        };
    Map bodyNotification =
        {
          "body":"Receive a patient from : ,\n $dropOffLocationAddress",
          "title":"New Request",
        };

    Map dataMap =
        {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "rideRequestId" : patientRideRequestId,
        };

    Map officialNotificationFormat  =
        {
          "notification": bodyNotification,
          "data" : dataMap,
          "priority": "high",
          "to" : deviceRegistrationToken,
        };
        
        var responseNotification = http.post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: headerNotification,
          body: jsonEncode(officialNotificationFormat),
        );
  }
}