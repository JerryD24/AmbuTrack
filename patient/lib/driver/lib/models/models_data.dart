import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverData
{
  //attributes
  String? id;
  String? name;
  String? phone;
  String? email;
  String? ambulanceNumber;
  String? hospitalName;
  String? patientName;
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;


  DriverData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.ambulanceNumber,
    this.hospitalName,
    this.patientName,
    this.originAddress,
    this.originLatLng,
    this.destinationAddress,
    this.destinationLatLng,

  });
}