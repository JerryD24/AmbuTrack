import 'package:flutter/material.dart';
import 'package:patient/assistants/request_assistant.dart';
import 'package:patient/global/global.dart';
import 'package:patient/global/map_key.dart';
import 'package:patient/models/directions.dart';
import 'package:patient/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../models/predicted_places.dart';

class PlacePredictedTileDesign extends StatefulWidget
{
  var predictedPlaces;

  PlacePredictedTileDesign({
   this.predictedPlaces
});

  @override
  State<PlacePredictedTileDesign> createState() => _PlacePredictedTileDesignState();
}

class _PlacePredictedTileDesignState extends State<PlacePredictedTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          message: "Please wait.",
        ),
    );
    String placeDirectionDetailsUrl ="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);


    if(responseApi == "request_assistant.dart")
      {
        Navigator.pop(context);
        return;
      }
    if(responseApi["status"] == "OK")
      {
        Directions directions = Directions();
        directions.locationName = responseApi["result"]["name"];
        directions.locationId = placeId;
        directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
        directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

        Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

        setState(() {
          patientDropOffLocation =directions.locationName!;
        });

        Navigator.pop(context,"obtainedDropoff");

      }Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context)
  {
    return ElevatedButton(
      onPressed: ()
      {
        getPlaceDirectionDetails(widget.predictedPlaces["place_id"],context);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            const Icon(Icons.add_location,color: Colors.grey,),

            const SizedBox(width: 14,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0,),
                  Text(
                    widget.predictedPlaces["name"],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 2.0,),

                  Text(
                    widget.predictedPlaces["vicinity"],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}