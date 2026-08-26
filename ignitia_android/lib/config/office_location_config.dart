import 'package:geolocator/geolocator.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/utils/string.dart';

class OfficeLocationConfig {
  OfficeLocationConfig._();

  // Master switch for the "prevent proxy attendance" location validation.
  // When disabled the app will only record the location but will not block
  // check-in / check-out from outside the office range.
  static const bool validationEnabled = true;

  // Set to true to force every check-in / check-out to provide a valid GPS
  // position. When false the app keeps the previous behaviour where web
  // clients could check in without location data.
  static const bool requireLocation = true;

  // Face capture is mandatory on mobile (native) builds. When running on web
  // the ML Kit detector is not available, so the photo is still captured and
  // sent to the server for verification but no local "face present" check runs.
  static const bool faceValidationEnabled = true;

  // The office centre + radius are overridable at build time, e.g.:
  //   flutter build/run --dart-define=OFFICE_LATITUDE=23.810331
  //                      --dart-define=OFFICE_LONGITUDE=90.412521
  //                      --dart-define=OFFICE_RADIUS_METERS=300
  // The values below are fallbacks only; the SERVER is the source of truth
  // for the geo-fence. Whenever the server-maintained office list is loaded
  // successfully it replaces this fallback (see setOffices).
  // double.fromEnvironment does not exist, so the values are read as strings
  // and parsed at startup.
  static final double officeLatitude = double.tryParse(
        String.fromEnvironment('OFFICE_LATITUDE'),
      ) ??
      23.810331;
  static final double officeLongitude = double.tryParse(
        String.fromEnvironment('OFFICE_LONGITUDE'),
      ) ??
      90.412521;
  static final double officeRadiusMeters = double.tryParse(
        String.fromEnvironment('OFFICE_RADIUS_METERS'),
      ) ??
      300;

  // Configure every office the employees are allowed to check in / out from.
  // An employee is considered on-site when the device position is inside the
  // radius of any of the registered offices.
  static final List<OfficeLocationModel> _offices = [
    OfficeLocationModel(
      name: "Head Office",
      latitude: officeLatitude,
      longitude: officeLongitude,
      radiusMeters: officeRadiusMeters,
    ),
  ];

  static List<OfficeLocationModel> get offices =>
      List.unmodifiable(_offices);

  // Replaces the geo-fence with the server-maintained office list. The server
  // is the source of truth, so when a list is received it fully overrides the
  // fallback entries. An empty list is ignored to avoid disabling the fence.
  static void setOffices(List<OfficeLocationModel> serverOffices) {
    if (serverOffices.isEmpty) return;
    _offices
      ..clear()
      ..addAll(serverOffices);
  }

  // Per-employee attendance geo-restriction. The value mirrors the
  // "attendance_location_type" field maintained on the employee profile:
  //   Office    -> validated against the assigned office / branch fences
  //   Home      -> validated against the employee home geo-fence
  //   Anywhere  -> no geo-restriction
  static String _attendanceLocationType = Strings.attendanceLocationTypeOffice;
  static double? _homeLatitude;
  static double? _homeLongitude;
  static double _homeRadiusMeters = 300;

  static String get attendanceLocationType => _attendanceLocationType;
  static double? get homeLatitude => _homeLatitude;
  static double? get homeLongitude => _homeLongitude;
  static double get homeRadiusMeters => _homeRadiusMeters;

  // Applies the current user's location restriction from their profile. The
  // device policy is refreshed at login, app start and after a profile update.
  static void setEmployeeLocationRestriction(
    String attendanceLocationType, {
    double? homeLatitude,
    double? homeLongitude,
    double homeRadiusMeters = 300,
  }) {
    _attendanceLocationType = attendanceLocationType.isEmpty
        ? Strings.attendanceLocationTypeOffice
        : attendanceLocationType;
    _homeLatitude = homeLatitude;
    _homeLongitude = homeLongitude;
    _homeRadiusMeters =
        homeRadiusMeters > 0 ? homeRadiusMeters : _homeRadiusMeters;
  }

  static bool isWithinOfficeRange(Position position) {
    if (!validationEnabled || _offices.isEmpty) return true;
    for (final office in _offices) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        office.latitude,
        office.longitude,
      );
      if (distance <= office.radiusMeters) {
        return true;
      }
    }
    return false;
  }

  static bool isWithinHomeRange(Position position) {
    if (_homeLatitude == null || _homeLongitude == null) return false;
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _homeLatitude!,
      _homeLongitude!,
    );
    return distance <= _homeRadiusMeters;
  }

  // Validates a position against the restriction defined on the current
  // user's profile. "Anywhere" employees always pass, "Home" employees are
  // validated against the home fence and everyone else against the offices.
  static bool isWithinAllowedRange(Position position) {
    if (!validationEnabled) return true;
    if (_attendanceLocationType.toLowerCase() ==
        Strings.attendanceLocationTypeAnywhere.toLowerCase()) {
      return true;
    }
    if (_attendanceLocationType.toLowerCase() ==
        Strings.attendanceLocationTypeHome.toLowerCase()) {
      return isWithinHomeRange(position);
    }
    return isWithinOfficeRange(position);
  }

  static double nearestOfficeDistanceMeters(Position position) {
    var nearest = double.maxFinite;
    for (final office in _offices) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        office.latitude,
        office.longitude,
      );
      if (distance < nearest) {
        nearest = distance;
      }
    }
    return nearest;
  }

  static double nearestHomeDistanceMeters(Position position) {
    if (_homeLatitude == null || _homeLongitude == null) {
      return double.maxFinite;
    }
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _homeLatitude!,
      _homeLongitude!,
    );
  }

  // Distance to the nearest fence relevant for the active restriction. This is
  // used only to produce a helpful error message when the position is outside
  // the allowed range.
  static double nearestAllowedDistanceMeters(Position position) {
    if (_attendanceLocationType.toLowerCase() ==
        Strings.attendanceLocationTypeHome.toLowerCase()) {
      return nearestHomeDistanceMeters(position);
    }
    return nearestOfficeDistanceMeters(position);
  }
}
