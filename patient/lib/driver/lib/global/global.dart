import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:patient/driver/lib/models/models_data.dart';
import 'package:patient/driver/lib/models/patientRideRequestInformation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';


final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionAmbulanceDriverLivePosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? driverCurrentPosition;
DriverData onlineDriverData = DriverData();
PatientRideRequestInformation patientRideRequestInformationSent = PatientRideRequestInformation();
List dList= [];
