import '../models/active_nearby_available_ambulance_drivers.dart';

class GeoFireAssistant
{
  static List<ActiveNearbyAvailableAmbulanceDrivers> activeNearbyAvailableAmbulanceDriversList = [];

  static void deleteOfflineDriverFromList(String driverId)
  {
    int indexNumber = activeNearbyAvailableAmbulanceDriversList.indexWhere((element) => element.driverId == driverId);
    activeNearbyAvailableAmbulanceDriversList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableAmbulanceDriverLocation(ActiveNearbyAvailableAmbulanceDrivers driverWhoMove)
  {
    int indexNumber = activeNearbyAvailableAmbulanceDriversList.indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activeNearbyAvailableAmbulanceDriversList[indexNumber].locationLatitude = driverWhoMove.locationLatitude;
    activeNearbyAvailableAmbulanceDriversList[indexNumber].locationLongitude = driverWhoMove.locationLongitude;
  }
}