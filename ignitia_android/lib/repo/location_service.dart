import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../config/office_location_config.dart';
import '../utils/message.dart';
import '../utils/string.dart';

class LocationService {
  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    //try{
    return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best)
        .onError((error, stackTrace) => Future.error('Location not found.'));
    // }catch(e){
    //   return null;
    // }
  }

  // Fetches the current position and validates it against the geo-fence
  // defined by the current employee's attendance location policy:
  //   - "Office"   -> the assigned office / branch ranges
  //   - "Home"     -> the employee home range
  //   - "Anywhere" -> no restriction, position is always accepted
  // When validation is enabled and the device is outside the allowed range,
  // a Future.error is returned so that the attendance flow is blocked and a
  // proxy check-in is not possible.
  Future<Position> getValidatedPosition() async {
    final position = await getGeoLocationPosition();
    final isWithin = OfficeLocationConfig.isWithinAllowedRange(position);
    if (!isWithin) {
      final isHome = OfficeLocationConfig.attendanceLocationType.toLowerCase() ==
          Strings.attendanceLocationTypeHome.toLowerCase();
      final distance =
          OfficeLocationConfig.nearestAllowedDistanceMeters(position);
      final String distanceLabel = isHome
          ? Messages.errorDistanceFromHome
          : Messages.errorDistanceFromOffice;
      return Future.error(
        '${isHome ? Messages.errorOutsideHomeRange : Messages.errorOutsideOfficeRange}\n'
        '$distanceLabel: ${distance.toStringAsFixed(0)} ${Messages.unitMeters}',
      );
    }
    return position;
  }

  Future<String> GetAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      if (kDebugMode) {
        print(address);
      }
      return address;
    } catch (e) {
      return "";
    }
  }
}
