import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class SelectNearestActiveAmbulanceDriversScreen extends StatefulWidget
{
  final DatabaseReference? referenceAmbulanceRequest;

  const SelectNearestActiveAmbulanceDriversScreen({super.key, this.referenceAmbulanceRequest});


  @override
  State<SelectNearestActiveAmbulanceDriversScreen> createState() => _SelectNearestActiveAmbulanceDriversScreenState();
}

class _SelectNearestActiveAmbulanceDriversScreenState extends State<SelectNearestActiveAmbulanceDriversScreen>
{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          "Nearest Ambulance Available",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
              Icons.close,color: Colors.white,
          ),
          onPressed: ()
          {
            //delete the ride request from database
            widget.referenceAmbulanceRequest!.remove();
            Fluttertoast.showToast(msg: "You have Cancelled the Ambulance.");          

            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder
        (
        itemCount: dList.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: ( BuildContext context, int index)
        {
          return GestureDetector(
            onTap: ()
            {
              setState(() {
                chosenDriverId = dList[index]["id"].toString();
              });
              Navigator.pop(context, "driverChosen");
            },
            child: Card(
              color: Colors.grey,
              elevation: 3,
              shadowColor: Colors.green,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Expanded(
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    // dList[index] ,
                      Text(
                        dList[index]["name"],
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        dList[index]["ambulance_details"]["Ambulance-number"],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
