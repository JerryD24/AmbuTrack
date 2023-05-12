
import 'package:patient/driver/lib/global/global.dart';
import 'package:patient/driver/lib/splashScreen/driver_splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AmbulanceInfoScreen extends StatefulWidget
{


  @override
  State<AmbulanceInfoScreen> createState() => _AmbulanceInfoScreenState();
}

class _AmbulanceInfoScreenState extends State<AmbulanceInfoScreen>
{

  TextEditingController hospitalNameTextEditingController = TextEditingController();
  TextEditingController ambulanceNumberTextEditingController = TextEditingController();
  TextEditingController driverNameTextEditingController = TextEditingController();

  saveAmbulanceInfo()
  {
    Map driversAmbulanceInfoMap =
    {
      "Hospital-name":hospitalNameTextEditingController.text.trim(),
      "Ambulance-number": ambulanceNumberTextEditingController.text.trim(),
      "Driver-name": driverNameTextEditingController.text.trim(),
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("Drivers");
    driversRef.child(currentFirebaseUser!.uid).child("ambulance_details").set(driversAmbulanceInfoMap);

    Fluttertoast.showToast(msg: "Ambulance information has been saved successfully.");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const DriverSplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [

              const SizedBox(height: 24,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/driver_logo.png"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Ambulance Details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: hospitalNameTextEditingController,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Hospital Name",
                  hintText: "Hospital Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: ambulanceNumberTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Ambulance Number",
                  hintText: "Ambulance Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: driverNameTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Driver Name",
                  hintText: "Driver Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  if(hospitalNameTextEditingController.text.isNotEmpty
                      && ambulanceNumberTextEditingController.text.isNotEmpty
                      && driverNameTextEditingController.text.isNotEmpty)
                    {
                      saveAmbulanceInfo();
                    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text(
                    "Save Now",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )


                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
