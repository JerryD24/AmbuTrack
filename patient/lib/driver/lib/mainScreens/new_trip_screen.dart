// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patient/driver/lib/mainScreens/main_screen.dart';
import 'package:patient/mainScreens/search_places_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../infoHandler/app_info.dart';
import '../../../widgets/progress_dialog.dart';
import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../models/patientRideRequestInformation.dart';

class NewTripScreen extends StatefulWidget {
  PatientRideRequestInformation? patientRideRequestDetails;

  NewTripScreen({super.key, this.patientRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;
  String statusBtn = "accepted";

  Set<Marker> setOfMarkers = <Marker>{};
  Set<Circle> setOfCircle = <Circle>{};
  Set<Polyline> setOfPolyline = <Polyline>{};
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;

  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  get patientPickUpLatLng => null;

  late LatLng patiientPickUpLocation;

  //Step 1:: when driver accepts the user ride request
  // originLatLng = driverCurrent Location
  // destinationLatLng = user PickUp Location

  //Step 2:: driver already picked up the user in his/her car
  // originLatLng = user PickUp Location => driver current Location
  // destinationLatLng = user DropOff Location
  Future<void> drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  createAmbulanceDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/pin(1).png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getAmbulanceDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionAmbulanceDriverLivePosition =
      Geolocator.getPositionStream().listen((Position position){
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      // FirebaseDatabase.instance
      //     .ref()
      //     .child("Ambulance Request")
      //     .child(widget.patientRideRequestDetails!.rideRequestId!)
      //     .child("DriverLocation")
      //     .set({"latitude":onlineDriverCurrentPosition!.latitude,"longitude":onlineDriverCurrentPosition!.longitude});

      LatLng latLngLiveDriverCurrentPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
          markerId: const MarkerId("AnimatedMarker"),
          position: latLngLiveDriverCurrentPosition,
          icon: iconAnimatedMarker!,
          infoWindow: const InfoWindow(title: "This is your Location."));

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverCurrentPosition, zoom: 16);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverCurrentPosition;
      updateDurationTimeAtRealTime();

      //updatingdriver location at real time in database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      // const dur= Duration(milliseconds: 3000);
      // Timer.periodic( dur, (timer) async{
      //   FirebaseDatabase.instance
      //     .ref()
      //     .child("Ambulance Request")
      //     .child(widget.patientRideRequestDetails!.rideRequestId!)
      //     .child("DriverLocation")
      //     .set(driverLatLngDataMap);
      //   });
            
      }
      ); 
      
      
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (onlineDriverCurrentPosition == null) {
        return;
      }

      var originLatlng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude); // Drive currentLocation

      LatLng? destinationLatlng;

      if (rideRequestStatus == "accepted") {
        destinationLatlng = widget
            .patientRideRequestDetails!.originLatLng;
          //   DatabaseReference dbReference = FirebaseDatabase.instance.ref("Ambulance Request").child("$uniqueId");
          // const dur= Duration(milliseconds: 3000);
          // Timer.periodic( dur, (timer) async{
            
          //   }
          // ); 
    //patient pickup location
      } else if(rideRequestStatus=="wayToHospital") {
        destinationLatlng = LatLng(Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLatitude!, Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLongitude!) ; //patient drop off location
      }
      else{
        destinationLatlng = widget.patientRideRequestDetails!.originLatLng;
      }

      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatlng, destinationLatlng!);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createAmbulanceDriverIconMarker();

    const dur= Duration(milliseconds: 3000);
          Timer.periodic( dur, (timer) async{

            
            if(rideRequestStatus=="wayToHospital"){
              Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
              // print("+++++++++++++++++++++++gggggggggggggggggggggg+++++++++++++=");
            FirebaseDatabase.instance
          .ref()
          .child("Ambulance Request")
          .child(widget.patientRideRequestDetails!.rideRequestId!)
          .child("DriverLocation")
          .set({"latitude":cPosition.latitude,"longitude":cPosition.longitude});
            }
            }
          ); 




    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              //black theme google map
              // blackThemedGoogleMap(newTripGoogleMapController);

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var patientPickUpLatLng =
                  widget.patientRideRequestDetails!.originLatLng;
                  
                  patiientPickUpLocation = widget.patientRideRequestDetails!.originLatLng!;
                  print("$patiientPickUpLocation------------------------------patlocccc");
              

              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, patientPickUpLatLng!);

              getAmbulanceDriversLocationUpdatesAtRealTime();
            },
          ),

          //ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    //duration
                    Text(
                      durationFromOriginToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    //user name - icon
                    Row(
                      children: [
                        Text(
                          widget.patientRideRequestDetails!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    //user PickUp Address with icon
                    Row(
                      children: [
                        // Image.asset(
                        //   "images/origin.png",
                        //   width: 30,
                        //   height: 30,
                        // ),
                        const SizedBox(
                          width: 14,
                        ),
                        SizedBox(
                        width: MediaQuery.of(context).size.width*3.3/4,
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


                    buttonTitle!="Arrived"? InkWell(
                          onTap: () async
                          {
                            //go to search places screen
                            var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=>const SearchPlacesScreen()));
                            if(responseFromSearchScreen == "obtainedDropoff")
                              {
                                showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext c) => ProgressDialog(
                                  message: "Please wait...",
                                ),
                              );

                              await drawPolyLineFromOriginToDestination(
                                  widget
                                      .patientRideRequestDetails!.originLatLng!,
                                      LatLng(Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLatitude!, Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLongitude!)
                                  
                                  );

                              Navigator.pop(context);
    
                              // DatabaseReference authorityReference =
                              //   FirebaseDatabase.instance
                              //       .ref("Ambulance Request")
                              //       .child(widget.patientRideRequestDetails!
                              //           .rideRequestId!);

                              // DatabaseEvent event =
                              //     await authorityReference.once();

                              // String destinationLatitude = (event.snapshot.value as Map)["destination"]["latitude"];
                              // String destinationLongitude =
                              //     (event.snapshot.value as Map)["destination"]
                              //         ["longitude"];
                              // String destinationAddress = (event.snapshot.value
                              //     as Map)["destinationAddress"];

                              // DatabaseReference databaseReferenceForAuthority =
                              //     FirebaseDatabase.instance
                              //         .ref() //For Authority
                              //         .child(
                              //             "Ambulance On Work") //For Authority
                              //         .child(widget.patientRideRequestDetails!
                              //             .rideRequestId!)
                              //         .child("driverId");

                              // databaseReferenceForAuthority
                              //     .child("destination")
                              //     .update({"latitude": destinationLatitude});
                              // databaseReferenceForAuthority
                              //     .child("destination")
                              //     .update({"longitude": destinationLongitude});

                              // databaseReferenceForAuthority.update(
                              //     {"destinationAddress": destinationAddress});
    
                              }
                          },
                          child: Padding(padding: const EdgeInsets.only(top: 5,bottom: 5) , child:  Row(
                            children: [
                               const Icon(Icons.add_location_alt_outlined,color: Colors.grey,),
                               const SizedBox(width: 12.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "To",
                                    style: TextStyle(
                                      color: Colors.grey,fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*3/4,
                                    child: Text(
                                      Provider.of<AppInfo>(context).patientDropOffLocation != null
                                          ? Provider.of<AppInfo>(context).patientDropOffLocation!.locationName!
                                          : "Select Hospital",
                                      style: const TextStyle(
                                        color: Colors.grey,fontSize: 16,),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ):Container(),

                    // const SizedBox(height: 20.0),

                    // //user DropOff Address with icon
                    // Row(
                    //   children: [
                    //     // Image.asset(
                    //     //   "images/destination.png",
                    //     //   width: 30,
                    //     //   height: 30,
                    //     // ),
                    //     const SizedBox(
                    //       width: 14,
                    //     ),
                    //     SizedBox(
                    //       width: MediaQuery.of(context).size.width*3.3/4,
                    //       child: Text(
                    //         widget.patientRideRequestDetails!
                    //             .destinationAddress!,
                    //         style: const TextStyle(
                    //           fontSize: 16,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 10.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buttonTitle=="Arrived" || buttonTitle=="Reached Hospital"? ElevatedButton.icon(
                          //Navigate Button
                          onPressed: () async {
                            String url = "";
                            
                            url = buttonTitle == "Reached Hospital"?
                             'https://www.google.com/maps/search/?api=1&query=${Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLatitude},${Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLongitude}&travelmode=driving'
                             :'https://www.google.com/maps/search/?api=1&query=${widget.patientRideRequestDetails!.originLatLng!.latitude},${widget.patientRideRequestDetails!.originLatLng!.longitude}&travelmode=driving';
                            if (await canLaunchUrlString(url))
                              await launchUrlString(url,
                                  mode:
                                      LaunchMode.externalNonBrowserApplication);
                          },
                          icon: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 25,
                          ),
                          label: Text(
                            "Navigate",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ):Container(),
                        buttonTitle=="Arrived" || buttonTitle=="Reached Hospital"? 
                        SizedBox(width: 10,):Container(),
                        ElevatedButton.icon(
                          //Arrived Button
                          onPressed: () async {
                            //Driver has arrived at User pick up Location
                            if (rideRequestStatus == "accepted") {
                              rideRequestStatus = "arrived";

                              FirebaseDatabase.instance
                                  .ref()
                                  .child("Ambulance Request")
                                  .child(widget.patientRideRequestDetails!
                                      .rideRequestId!)
                                  .child("status")
                                  .set(rideRequestStatus);

                              setState(() {
                                buttonTitle = "Start Ambulance";
                                buttonColor = Colors.lightBlueAccent;
                              });
                            }
                            //Patient is already in the ambulance
                            else if (rideRequestStatus == "arrived") {
                              if(Provider.of<AppInfo>(context,listen: false).patientDropOffLocation == null){
                                Fluttertoast.showToast(msg: "Select Hospital to start");
                                return;
                              }
                              rideRequestStatus = "wayToHospital";

                              FirebaseDatabase.instance
                                  .ref()
                                  .child("Ambulance Request")
                                  .child(widget.patientRideRequestDetails!
                                      .rideRequestId!)
                                  .child("status")
                                  .set(rideRequestStatus);
                              FirebaseDatabase.instance
                                  .ref()
                                  .child("Ambulance Request")
                                  .child(widget.patientRideRequestDetails!
                                      .rideRequestId!)
                                  .child("destination")
                                  .set({"Lat":Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLatitude,"Long":Provider.of<AppInfo>(context,listen:false).patientDropOffLocation!.locationLongitude});

                              setState(() {
                                buttonTitle = "Reached Hospital";
                                buttonColor = Colors.redAccent;
                              });
                            } else if (rideRequestStatus == "wayToHospital") {
                              endTripNow();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          icon: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 25,
                          ),
                          label: Text(
                            buttonTitle!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  endTripNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext c) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    FirebaseDatabase.instance
      .ref()
      .child("Ambulance Request")
      .child(widget.patientRideRequestDetails!.rideRequestId!)
      .child("status")
      .set("ended")
      .then((value) => {
        FirebaseDatabase.instance
          .ref()
          .child("Drivers")
          .child(currentFirebaseUser!.uid)
          .child("newRideStatus")
          .set("idle")
          .then((value) => {
            FirebaseDatabase.instance
              .ref("Ambulance Request")
              .child(widget.patientRideRequestDetails!.rideRequestId!)
              .remove()
          }),
    });
    /////////////////////////////////////   For Authority
    FirebaseDatabase.instance
      .ref("Ambulance On Work") //For Authority
      .child(widget.patientRideRequestDetails!.rideRequestId!) //For Authority
      .remove(); //For Authority

    /////////////////////////////////////

    // Navigator.pop(context);

    streamSubscriptionAmbulanceDriverLivePosition!.cancel();
    // Navigator.pop(context);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=> MainScreen()),(Route<dynamic> route) => false);
  }

  saveAssignedDriverDetailsToUserRideRequest() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child("Ambulance Request")
      .child(widget.patientRideRequestDetails!.rideRequestId!)
      .child("driverId");

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("DriverLocation").set(driverLocationDataMap);
    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);
    databaseReference.child("ambulanceNumber").set(onlineDriverData.ambulanceNumber);

//////////////////////////////////////////For Authority///////////////////////////////////////////////////

    DatabaseReference databaseReferenceForAuthority = FirebaseDatabase.instance
      .ref() //For Authority
      .child("Ambulance On Work") //For Authority
      .child(widget.patientRideRequestDetails!.rideRequestId!)
      .child("driverId");
    Map driverLocationDataMapForAuthority = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReferenceForAuthority
      .child("DriverLocation")
      .set(driverLocationDataMapForAuthority);

    databaseReferenceForAuthority
      .child("driverName")
      .set(onlineDriverData.name);
    databaseReferenceForAuthority
      .child("driverPhone")
      .set(onlineDriverData.phone);
    databaseReferenceForAuthority
      .child("ambulanceNumber")
      .set(onlineDriverData.ambulanceNumber);
        // print(widget.patientRideRequestDetails!.originLatLng!.latitude.toString()+"-----------------------------------patientloc");
    databaseReferenceForAuthority
      .child("patientPikUpLocation")
      .set({"Address":widget.patientRideRequestDetails!.originAddress,"Lat":widget.patientRideRequestDetails!.originLatLng!.latitude,"Long":widget.patientRideRequestDetails!.originLatLng!.longitude});

    DatabaseReference authorityReference = FirebaseDatabase.instance
      .ref("Ambulance Request")
      .child(widget.patientRideRequestDetails!.rideRequestId!);
    var ambulanceNumber = onlineDriverData.ambulanceNumber;

    DatabaseEvent event = await authorityReference.once();

    String originAddress = (event.snapshot.value as Map)["originAddress"];
    String destinationAddress = (event.snapshot.value as Map)["destinationAddress"];

    String originLatitude = (event.snapshot.value as Map)["origin"]["latitude"];
    String originLongitude = (event.snapshot.value as Map)["origin"]["longitude"];

    // String destinationLatitude = (event.snapshot.value as Map)["destination"]["latitude"];
    // String destinationLongitude = (event.snapshot.value as Map)["destination"]["longitude"];

    // databaseReferenceForAuthority.child("originAddress").set(originAddress);
    // databaseReferenceForAuthority
    //     .child("destinationAddress")
    //     .set(originAddress);

    // databaseReferenceForAuthority
    //     .child("origin")
    //     .child("latitude")
    //     .set(originLatitude);
    // databaseReferenceForAuthority
    //     .child("origin")
    //     .child("longitude")
    //     .set(originLongitude);

    // databaseReferenceForAuthority
    //     .child("destination")
    //     .child("latitude")
    //     .set(originLatitude);
    // databaseReferenceForAuthority
    //     .child("destination")
    //     .child("longitude")
    //     .set(originLongitude);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    saveRideRequestIdToDriverHistory();
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
      .ref()
      .child("Drivers")
      .child(currentFirebaseUser!.uid)
      .child("tripsHistory");

    tripsHistoryRef
      .child(widget.patientRideRequestDetails!.rideRequestId!)
      .set(true);
  }
}
