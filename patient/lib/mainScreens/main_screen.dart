// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patient/assistants/assistant_methods.dart';
import 'package:patient/assistants/geofire_assistant.dart';
import 'package:patient/mainScreens/search_places_screen.dart';
import 'package:patient/mainScreens/select_nearest_online_ambulance_drivers_screen.dart';
import 'package:patient/mainScreens/toggle_screen.dart';
import 'package:patient/models/active_nearby_available_ambulance_drivers.dart';
import 'package:patient/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../widgets/my_drawer.dart';

class MainScreen extends StatefulWidget   //Patient Main Screen
{
  const MainScreen({super.key});



  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController ;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight =220.0;
  double waitingResponseFromDriverContainerHeight =0;
  double assignedDriverInfoContainerHeight =0;

  Position? patientCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  List<LatLng> pLinesCoOrdinatesList = [];
  Set<Polyline> polyLineSet ={};

  Set<Marker> markersSet = {};
  Set<Circle> circleSet = {};

  String patientName = "Your Name";
  String patientEmail ="Your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyDriversKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;


  List<ActiveNearbyAvailableAmbulanceDrivers> onlineNearbyAvailableAmbulanceDriversList = [];


  DatabaseReference?  referenceAmbulanceRequest;
  String ambulanceDriverRideStatus = "Ambulance is on its way.";
  StreamSubscription<DatabaseEvent>? ambulanceCallRequestStreamSubscription;
  String patientRideRequestStatus = "";
  bool requestPositionInfo = true;

  //for Authority/////////////////////////////

  DatabaseReference?  referenceDriverAcceptRequest;

  /////////////////////////////////

  blackThemedGoogleMap()    //uncomment for black theme of google map
  {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                   ''');
  }

  checkIfLocationPermissionAllowed()
  async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
      {
        _locationPermission = await Geolocator.requestPermission();
      }
  }

  locateUserPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    patientCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(patientCurrentPosition!.latitude, patientCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(patientCurrentPosition!, context);
    print("This is your address = $humanReadableAddress");

    patientName = userModelCurrentInfo!.name!;
    patientEmail = userModelCurrentInfo!.email! ;

    initializeGeoFireListener();
  }

  saveRideRequestInformation() async
  {
    //1. save the ride request information
    referenceAmbulanceRequest = FirebaseDatabase.instance.ref().child("Ambulance Request").push();

    var originLocation = Provider.of<AppInfo>(context,listen: false).patientPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context,listen: false).patientDropOffLocation;

    Map originLocationMap =
    {
      //Key : value,

      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

  Map destinationLocationMap =
    {
    //Key : value,

    "latitude": destinationLocation!.locationLatitude.toString(),
    "longitude": destinationLocation.locationLongitude.toString(),
    };

  Map patientInformationMap =
  {
    "origin": originLocationMap,
    "destination" : destinationLocationMap,
    "time" : DateTime.now().toString(),
    "userName" : userModelCurrentInfo!.name,
    "userPhone" : userModelCurrentInfo!.phone,
    "originAddress" : originLocation.locationName,
    "destinationAddress" : destinationLocation.locationName,
    "driverId" : "waiting",
  };

  referenceAmbulanceRequest!.set(patientInformationMap);
   onlineNearbyAvailableAmbulanceDriversList = GeoFireAssistant.activeNearbyAvailableAmbulanceDriversList;
    await searchNearestOnlineDrivers();

  ///////////////////////////////////////////////////Authority//////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    ambulanceCallRequestStreamSubscription = referenceAmbulanceRequest!.onValue.listen((eventSnap)
    {
      if(eventSnap.snapshot.value == null || (eventSnap.snapshot.value as Map)["driverId"]=="waiting" )
      {
          return;
      }
      print("${eventSnap.snapshot.value}-----------------------------------");
      if((eventSnap.snapshot.value as Map)["driverId"]["driverName"] != null)
      {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverId"]["driverName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverId"]["driverPhone"] != null)
      {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverId"]["driverPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null)
        {
          patientRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
        }

      if((eventSnap.snapshot.value as Map)["DriverLocation"] != null)
      {
       double driverCurrentPositionLat =  double.parse((eventSnap.snapshot.value as Map)["DriverLocation"]["latitude"].toString());
       double driverCurrentPositionLng =  double.parse((eventSnap.snapshot.value as Map)["DriverLocation"]["longitude"].toString());

       LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

       //status == accepted
        if(patientRideRequestStatus =="accepted")
          {
            updateArrivalTimeToPatientPickUpLocation(driverCurrentPositionLatLng);
            referenceDriverAcceptRequest!.set(patientInformationMap);
          }

        //status == onitsway
       if(patientRideRequestStatus =="arrived")
       {
          setState(() {
            ambulanceDriverRideStatus = "Ambulance is Arrived.";
          });
       }

        //status == start
       if(patientRideRequestStatus =="Way To Hospital")
       {
         updateReachingTimeToPatientDropOffLocation(driverCurrentPositionLatLng);
       }

      }
    });


  }

  updateArrivalTimeToPatientPickUpLocation(driverCurrentPositionLatLng) async
  {

   if(requestPositionInfo == true)
     {
       requestPositionInfo = false;

       LatLng patientPickUpPosition = LatLng(patientCurrentPosition!.latitude, patientCurrentPosition!.longitude) ;

       var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
         driverCurrentPositionLatLng,
         patientPickUpPosition
       );

       if(directionDetailsInfo == null)
         {
           return;
         }

       setState(() {
          ambulanceDriverRideStatus ="Ambulance will reach to you in ${directionDetailsInfo.duration_text}";
       });
       requestPositionInfo = true;
     }
  }

  updateReachingTimeToPatientDropOffLocation(driverCurrentPositionLatLng) async
  {

    if(requestPositionInfo == true)
    {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen:  false).patientDropOffLocation;

      LatLng patientDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!
      );

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng,
          patientDestinationPosition,
      );

      if(directionDetailsInfo == null)
      {
        return;
      }

      setState(() {
        ambulanceDriverRideStatus ="Will reach Hospital in  ${directionDetailsInfo.duration_text}";
      });
      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers() async
  {
    //when no active driver available
    if(onlineNearbyAvailableAmbulanceDriversList.isEmpty)
      {
        //Cancel the ride request

        referenceAmbulanceRequest!.remove();

        setState(() {
          polyLineSet.clear();
          markersSet.clear();
          circleSet.clear();
          pLinesCoOrdinatesList.clear();
        });

        Fluttertoast.showToast(msg: "Search again after some time.");

        // Future.delayed(const Duration(milliseconds: 3000),()
        // {
        //   SystemNavigator.pop();
        // });

        return;
      }

    //active driver available
    await retrieveOnlineAmbulanceDriverInformation(onlineNearbyAvailableAmbulanceDriversList);

    var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveAmbulanceDriversScreen(referenceAmbulanceRequest: referenceAmbulanceRequest)));
  
    if(response == "driverChosen")
      {
        FirebaseDatabase.instance.ref()
            .child("Drivers")
            .child(chosenDriverId!)
            .once()
            .then((snap)
        {
          if(snap.snapshot.value != null)
            {
              //sent notification to that specific Driver
              sendNotificationToDriverNow(chosenDriverId!);

              //display waiting Response ui from driver

              showWaitingResponseFromDriverUI();

                              //Response from driver

              FirebaseDatabase.instance.ref()
                  .child("Drivers")
                  .child(chosenDriverId!)
                  .child("newRideStatus")
                  .onValue.listen((eventSnapshot)
              {
                //1.Cancel the Ride Request :: Push Notification
                //(newRiseStatus = idle)

                if(eventSnapshot.snapshot.value == "idle")
                  {
                    Fluttertoast.showToast(msg: "Driver has cancelled your Request. Please choose another Driver.");

                    Navigator.push(context, MaterialPageRoute(builder: (c)=>  const MainScreen()));
                  }


                //2.Accept the Ride Request :: Push Notification
                //(newRiseStatus = accepted)
                if(eventSnapshot.snapshot.value == "accepted")
                {
                  showUIForAssignedDriverInfo();
                }
              });
            }
          else
            {
              Fluttertoast.showToast(msg: "This Driver do not exist.");
            }
        });
      }
  }

  showUIForAssignedDriverInfo()
  {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromDriverUI()
  {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;

    });
  }

  sendNotificationToDriverNow(String chosenDriverId)
  {
    //assign riderequest to newRideStatus in drivers parent node for that specific chosen Driver
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceAmbulanceRequest?.key);
    
    
    //Automate the push notification
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("token").once().then((snap)
    {
      if(snap.snapshot.value != null)
        {
          String deviceRegistrationToken = snap.snapshot.value.toString();

          //send Notification
          AssistantMethods.sendNotificationToDriverNow(
              deviceRegistrationToken,
              referenceAmbulanceRequest!.key.toString(),
              context,
          );
          Fluttertoast.showToast(msg: "Notification Sent Successfully.");

        }
      else
        {
          Fluttertoast.showToast(msg: "Please select another Driver.");
          return;
        }
    });

  }

  retrieveOnlineAmbulanceDriverInformation(List onlineNearestAmbulanceDriversList) async
  {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("Drivers");
      for(int i=0;i<onlineNearestAmbulanceDriversList.length; i++)
      {
         await ref.child(onlineNearestAmbulanceDriversList[i].driverId.toString())
            .once()
            .then((dataSnapshot)
        {
          var driverKeyInfo =dataSnapshot.snapshot.value;
          dList.add(driverKeyInfo);

        });
      }

  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyAmbulanceDriverIconMarker();

    return SafeArea(
      child: Scaffold(
        key: sKey,
        drawer : SizedBox(
          width: 280,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.black,
            ),
            child: MyDrawer(
              name: patientName,
              email: patientEmail,
            ),
          ),
        ),
        body: Stack(
          children: [
    
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition:_kGooglePlex,
              polylines: polyLineSet,
              markers: markersSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller)
              {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
    
                // //for Black theme Google Map
                // blackThemedGoogleMap();
    
                locateUserPosition();
              },
            ),
    
            //custom hamburger button for drawer
            Positioned(
              top: 45,
              left: 22,
              child: GestureDetector(
                onTap: ()
                {
                  if(openNavigationDrawer)
                    {
                      sKey.currentState!.openDrawer();
                    }
                  else
                    {
                      //restart or refresh app automatically, in order to refresh stats of the app
                      // SystemNavigator.pop();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c)=> const ToggleScreenPage()),(Route<dynamic> route) => false);
                    }
    
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(
                    openNavigationDrawer ? Icons.menu : Icons.close,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
    
            //ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  // height: searchLocationContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                    child: Column(
                      children: [
                        //from (current location)
                        InkWell(
                          onTap: (){setState(() {
                            
                          });},
                          child: Padding(padding: const EdgeInsets.only(top: 5,bottom: 5,),
                          child: 
                          Row(
                            children: [
                              const Icon(Icons.add_location_alt_outlined,color: Colors.grey,),
                              const SizedBox(width: 12.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Current Location",
                                    style: TextStyle(
                                      color: Colors.grey,fontSize: 12,),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*3/4,
                                    child: Text(
                                      Provider.of<AppInfo>(context).patientPickUpLocation != null
                                          ? "${(Provider.of<AppInfo>(context).patientPickUpLocation!.locationName!).substring(0,35)}..."
                                          : "Obtaining address",
                                      style: const TextStyle(
                                        color: Colors.grey,fontSize: 14,),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ),
    
                        const SizedBox(height: 10,),
    
                        const Divider(
                          height: 1,
                            thickness: 1,
                            color: Colors.grey,
                        ),
    
                        const SizedBox(height: 16.0,),
    
                        //to
                        InkWell(
                          onTap: () async
                          {
                            //go to search places screen
                            var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=>const SearchPlacesScreen()));
    
                            if(responseFromSearchScreen == "obtainedDropoff")
                              {
                                setState(() {
                                  openNavigationDrawer = false;
                                });
    
                                //draw routes- draw poly line
                                await drawPolyLineFromOriginToDestination();
    
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
                                      color: Colors.grey,fontSize: 12,),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*3/4,
                                    child: Text(
                                      Provider.of<AppInfo>(context).patientDropOffLocation != null
                                          ? Provider.of<AppInfo>(context).patientDropOffLocation!.locationName!
                                          : "Select Hospital",
                                      style: const TextStyle(
                                        color: Colors.grey,fontSize: 14,),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        ),
    
                        const SizedBox(height: 10,),
    
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
    
                        const SizedBox(height: 16.0,),
    
                        ElevatedButton(
                          onPressed: ()
                          {
                            if(Provider.of<AppInfo>(context,listen: false).patientDropOffLocation != null)
                              {
                                saveRideRequestInformation();
                              }
                            else
                              {
                                Fluttertoast.showToast(msg: "Please Select Destination First!");
                              }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                          ),
                          child: const Text(
                            "Request Ambulance",
                          ),
                        ),
    
                      ],
                    ),
                  ),
                ),
              ),
            ),
    
            //ui for waiting response from driver
            Positioned(
              bottom: 0,
              left:0,
              right: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'Waiting for response from Driver...',
                          textAlign: TextAlign.center,
                          duration: const Duration(milliseconds: 5000),
                          textStyle: const TextStyle(fontSize: 20.0,color: Colors.lightBlue, fontWeight: FontWeight.bold),
                        ),
                        ScaleAnimatedText(
                          'Please Wait...',
                          textAlign: TextAlign.center,
                          duration: const Duration(milliseconds: 4000),
                          textStyle: const TextStyle(fontSize: 25.0,color: Colors.lightBlue, fontFamily: 'Canterbury'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    
            //ui for displaying assigned driver information
            Positioned(
              bottom: 0,
              left:0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //status of the Ride
                      Center(
                        child: Text(
                          ambulanceDriverRideStatus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
    
                      const SizedBox(height: 20.0,),
    
                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.white60,
                      ),
    
                      const SizedBox(height: 20.0,),
                      //driver name
    
                      Center(
                        child: Text(
                          driverName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
    
                      const SizedBox(height: 2.0,),
    
                      //Driver Vehicle Detail
                      Center(
                        child: Text(
                          driverPhone,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
    
    
    
                      const SizedBox(height: 20.0,),
    
                      const Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.white60,
                      ),
    
                      const SizedBox(height: 20.0,),
    
                      //call driver button
                      Center(
                        child: ElevatedButton.icon(
                            onPressed: ()
                            {
    
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
    
                            icon: const Icon(Icons.phone_android,
                            color: Colors.black54,
                              size: 22,
                            ),
                            label: const Text(
                              "Call Driver",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
    
                              ),
                            ),
                        ),
                      ),
    
                    ],
                  ),
                ),
    
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async
  {
    var originPosition = Provider.of<AppInfo>(context, listen: false).patientPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).patientDropOffLocation;

    var originLatLng =LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng =LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context)=> ProgressDialog(message:"Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are Points :  ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLinesCoOrdinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
      {
        for (var pointLatLng in decodedPolyLinePointsResultList) {
          pLinesCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }
      }

    polyLineSet.clear();

    setState(() {
      Polyline polyLine =Polyline(
        color: Colors.blueAccent,
        polylineId: const PolylineId("PolylineId"),
        jointType: JointType.round,
        points: pLinesCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyLine);
    });

    LatLngBounds boundsLatlng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
      {
        boundsLatlng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
      }

    else if(originLatLng.longitude > destinationLatLng.longitude)
      {
        boundsLatlng = LatLngBounds(
            southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
            northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        );
      }

    else if(originLatLng.latitude > destinationLatLng.latitude )
    {
      boundsLatlng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
      {
        boundsLatlng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
      }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatlng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originId"),
      infoWindow: InfoWindow(title: originPosition.locationName,snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      infoWindow: InfoWindow(title: destinationPosition.locationName,snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      // markersSet.add(originMarker);
      markersSet.add(destinationMarker);
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
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        patientCurrentPosition!.latitude, patientCurrentPosition!.longitude, 10000)!
        .listen((map) {
      // print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //whenever any driver become active- online
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableAmbulanceDrivers activeNearbyAvailableAmbulanceDriver = ActiveNearbyAvailableAmbulanceDrivers();
            activeNearbyAvailableAmbulanceDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableAmbulanceDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableAmbulanceDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableAmbulanceDriversList.add(activeNearbyAvailableAmbulanceDriver);
            if(activeNearbyDriversKeysLoaded == true)
              {
                displayActiveDriversOnPatientMap();
              }
            break;

          //whenever any driver become NonActive- offline
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnPatientMap();
            break;

          //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableAmbulanceDrivers activeNearbyAvailableAmbulanceDriver = ActiveNearbyAvailableAmbulanceDrivers();
            activeNearbyAvailableAmbulanceDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableAmbulanceDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableAmbulanceDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableAmbulanceDriverLocation(activeNearbyAvailableAmbulanceDriver);
            displayActiveDriversOnPatientMap();
            break;

          //display online drivers on  patient map
          case Geofire.onGeoQueryReady:
            activeNearbyDriversKeysLoaded = true;
            displayActiveDriversOnPatientMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnPatientMap()
  {
    setState(() {
      markersSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = <Marker>{};

      for(ActiveNearbyAvailableAmbulanceDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableAmbulanceDriversList)
        {
          LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!,eachDriver.locationLongitude!);

          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: activeNearbyIcon!,
            rotation: 360,
          );

          driversMarkerSet.add(marker);
        }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });
  }

  createActiveNearbyAmbulanceDriverIconMarker()
  {
    if(activeNearbyIcon == null)
      {
        ImageConfiguration imageConfiguration = createLocalImageConfiguration(context,size: const Size(1, 1));
        BitmapDescriptor.fromAssetImage(imageConfiguration,"images/pin.png").then((value)
        {
          activeNearbyIcon = value;
        });
      }
  }
}
