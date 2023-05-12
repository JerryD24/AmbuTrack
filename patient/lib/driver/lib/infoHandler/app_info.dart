import 'package:flutter/cupertino.dart';

import '../models/directions.dart';


class AppInfo extends ChangeNotifier
{
  Directions? patientPickUpLocation, patientDropOffLocation;


  void updatePickUpLocationAddress(Directions patientPickUpAddress)
  {
    patientPickUpLocation = patientPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions patientDropOffAddress)
  {
    patientDropOffLocation = patientDropOffAddress;
    notifyListeners();
  }
}