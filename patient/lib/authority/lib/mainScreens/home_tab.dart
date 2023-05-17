import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import 'map_route.dart';

class HomeTabScreen extends StatefulWidget {
  

  @override
  State<HomeTabScreen> createState() => _HomeTabScreen();
}

class _HomeTabScreen extends State<HomeTabScreen> {
  
  final ambulanceOnWorkReference = FirebaseDatabase.instance.ref("Ambulance On Work");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('Drivers on Work',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 34,
              color: Colors.white),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: FirebaseAnimatedList(
                  query: ambulanceOnWorkReference,
                  itemBuilder: (context, snapshot, animation, index)
              {
                return GestureDetector(
                    onTap: ()
                    {
                      setState(() {
                        uniqueId = snapshot.key;
                        chosenDriverId = snapshot.child("driverId").toString();
                        sourceLocationLatitude = (snapshot.value as Map)["driverId"]["DriverLocation"]["latitude"].toString();
                        sourceLocationLongitude =(snapshot.value as Map) ["driverId"]["DriverLocation"]["longitude"].toString();

                        destinationLocationLatitude= (snapshot.value as Map)["driverId"]["patientPikUpLocation"]["Lat"].toString();
                        destinationLocationLongitude=(snapshot.value as Map)["driverId"]["patientPikUpLocation"]["Long"].toString();
                      });
                      //Change LoginScreen() to OrderTrackingPage
                      //Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                      // Navigator.pop(context, "driverChosen");
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> MapRouteScreen()));
                    },
                    child: ListTile(
                      tileColor: Colors.white38,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.child("driverId").child("driverName").value.toString(),
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),

                            Text(
                              snapshot.child("driverId").child("driverPhone").value.toString(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),

                            Text(
                                snapshot.child("driverId").child("ambulanceNumber").value.toString(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                            Text(
                              snapshot.child("driverId").child("patientPikUpLocation").child("Address").value.toString(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                );
              }),
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false, //Removing Debug Banner
    );
  }
}

