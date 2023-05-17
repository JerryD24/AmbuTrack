import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patient/authority/lib/global/global.dart';
import 'package:patient/authority/lib/mainScreens/home_tab.dart';

import '../global/map_key.dart';


class MapRouteScreen extends StatefulWidget {
  HomeTabScreen? homeTabScreen;

  MapRouteScreen({super.key, 
    this.homeTabScreen
  });

  @override
  State<MapRouteScreen> createState() => MapRouteScreenState();
}

class MapRouteScreenState extends State<MapRouteScreen> {


  final Completer<GoogleMapController> _controller = Completer();

  LatLng sourceLocation=LatLng(double.parse(sourceLocationLatitude!), double.parse(sourceLocationLongitude!));
  LatLng destinationLocation= LatLng(double.parse(destinationLocationLatitude!), double.parse(destinationLocationLongitude!));



  List<LatLng> polylineCoordinates=[];


  Future<Position> getCurrentLocation() async {   //give current location
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    // Request location permissions
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied){
      throw 'Location permissions are denied';
    } else if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    // Get the current location
    return Geolocator.getCurrentPosition();
  }
  void getRealTimeLocationUpdate()  {
    DatabaseReference dbReference = FirebaseDatabase.instance.ref("Ambulance Request").child("$uniqueId");
    const dur= Duration(milliseconds: 3000);
    Timer.periodic( dur, (timer) async{
      DatabaseEvent event = await dbReference.once();
      setState(() {
        sourceLocationLatitude = (event.snapshot.value as Map)["DriverLocation"]["latitude"].toString();
        sourceLocationLongitude =(event.snapshot.value as Map) ["DriverLocation"]["longitude"].toString();
        sourceLocation=LatLng(double.parse(sourceLocationLatitude.toString()), double.parse(sourceLocationLongitude.toString()));
        print(sourceLocation.toString()+"+++++++++++++++++++++++++++++++++++++++++++++++");
      });
      
      
      var snap = event.snapshot.value as Map;

      // print("------------------------------auth");
      if(snap["destination"]!=null){
        destinationLocationLatitude = snap["destination"]["Lat"].toString();
        destinationLocationLongitude = snap["destination"]["Long"].toString();
        destinationLocation = LatLng(double.parse(destinationLocationLatitude!), double.parse(destinationLocationLongitude!));
      }
      getPolyPoints();
    });
  }
  void getPolyPoints() async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey,
      PointLatLng(sourceLocation.latitude,sourceLocation.longitude),
      PointLatLng(destinationLocation.latitude,destinationLocation.longitude),
    );
    if(result.points.isNotEmpty){
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude,point.longitude),
        );
      }
      setState(() {});
    }
  }
  @override
  void initState() {
    // currentLocation=getCurrentLocation();
    getRealTimeLocationUpdate();
    getPolyPoints();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ambulance Tracking route",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:GoogleMap(initialCameraPosition: CameraPosition(target: sourceLocation,zoom: 16.5,
      ),
        myLocationEnabled: false,
        mapType: MapType.normal,
        polylines:{
          Polyline(polylineId:const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.redAccent,
            width: 6,
          )
        },
        markers:{
          Marker(
            markerId: const MarkerId("source"),
            position: sourceLocation,
          ), //Marker
          Marker(
            markerId: const MarkerId("destination"),
            position: destinationLocation,
          ),
          Marker(
            markerId: const MarkerId("liveLocation"),
            position: sourceLocation,
          ),
        },
      ),
    );
  }
}