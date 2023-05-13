import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patient/assistants/request_assistant.dart';
import 'package:patient/models/predicted_places.dart';
import 'package:patient/widgets/place_prediction_tile.dart';

import '../global/map_key.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen>
{
  List placePredictedList = [];

  void findPlaceAutoCompleteSearch() async
  {
   
        Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng latLngPosition = LatLng(cPosition!.latitude, cPosition!.longitude);
    String lat = cPosition.latitude.toString(),lon = cPosition.longitude.toString();
        String urlAutoCompleteSearch =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=Hospital&location=$lat,$lon&rankby=distance&type=hospitals&key=$mapKey";
        // "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IN";
        // "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=Hospitals near me&location=$lat,$lon&rankby=distance &type=hospital&key=$mapKey";
        var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
        print("Got-------------------------------------"+responseAutoCompleteSearch.toString());
        if(responseAutoCompleteSearch == "Error occurred,Failed.No response")
          {
            return;
          }


        if(responseAutoCompleteSearch["status"] == "OK")
          {
            var placePredictions = responseAutoCompleteSearch["results"];

            // var placePredictionsList = (placePredictions as List).map((jsonData)=> PredictedPlaces.fromJson(jsonData)).toList();
            print("============================="+placePredictions.toString());

            setState(() {
              placePredictedList = placePredictions;
            });
          }
      
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    findPlaceAutoCompleteSearch();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            //search place ui
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Colors.black54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7
                    )
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
    
                    const SizedBox(height: 25.0,),
    
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: ()
                          {
                            Navigator.pop(context);
                           },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                          ),
                        ),
    
                        const Center(
                          child: Text(
                            "Search & Dropoff Location",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        )
    
                      ],
                    ),
                    const SizedBox(height: 16,),
    
                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 18,),
    
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (valueTyped)
                              {
                                findPlaceAutoCompleteSearch();
                              },
                              decoration: const InputDecoration(
                                hintText: "Search here...",
                                fillColor: Colors.white54,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        )
    
                      ],
                    ),
                  ],
                ),
              ),
            ),
    
            //display place predictions result
            (placePredictedList.length > 0)
                ? Expanded(
              child: ListView.separated(
                itemCount: placePredictedList.length,
                physics: ClampingScrollPhysics(),
                itemBuilder:(context,index)
                {
                  return PlacePredictedTileDesign(
                    predictedPlaces: placePredictedList[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index)
                {
                  return const Divider(
                    height: 1,
                    color: Colors.grey,
                    thickness: 1,
                  );
                },
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
