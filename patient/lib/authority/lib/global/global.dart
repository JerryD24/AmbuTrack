import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
List dRList = [];  //Stores Drivers Request Key
String? chosenDriverId ="";
String? sourceLocationLatitude= "";
String? sourceLocationLongitude= "";
String? destinationLocationLatitude="";
String? destinationLocationLongitude="";
LatLng? sourceLocation;
LatLng? destinationLocation;
String? uniqueId="";