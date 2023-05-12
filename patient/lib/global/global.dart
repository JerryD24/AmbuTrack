import 'package:firebase_auth/firebase_auth.dart';
import 'package:patient/models/user_model.dart';

import '../models/direction_details_info.dart';


final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; // online Drivers info list
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId ="";
String cloudMessagingServerToken = "key=AAAACje8iw4:APA91bFC7-qpdy9wMoqJ1lx5hhIJoOZ_u-MSLMEOiBMPbl2rBRufVSGMWtVMUv9gMWvM7pp01oOaW7ZpD1NxpyiYzXPI_oC_cS-xCTxeCBeFLvec9PdWkpkBA-u4IgvD6ghVMlHRp6YV";
String patientDropOffLocation = "";
String ambulanceDriverDetails = "";
String ambulanceNumber="";
String driverName = "";
String driverPhone ="";
String originAddress ="";
int toggleIndex=0;