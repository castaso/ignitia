import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/repo/office_location_services.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/view_models/base_view_model.dart';

class OfficeLocationViewModel extends BaseViewModel {
  OfficeLocationViewModel() {
    loadOfficeLocations();
  }

  List<OfficeLocationModel> _officeLocationList = [];
  List<OfficeLocationModel> get officeLocationList => _officeLocationList;
  _setOfficeLocationList(List<OfficeLocationModel> list) {
    _officeLocationList = list;
    notifyListeners();
  }

  // Fetches the server-maintained office list and applies it to the
  // geo-fence configuration so that check-in / check-out is validated
  // against the maintained office locations.
  Future loadOfficeLocations() async {
    setErrorMsg("");
    setLoading(true);

    var res = await OfficeLocationService.getOfficeLocationList();
    if (res is Success) {
      var data = res.response as List<OfficeLocationModel>;
      _setOfficeLocationList(data);
      OfficeLocationConfig.setOffices(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future<bool> addOfficeLocation(OfficeLocationModel officeLocationModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateOfficeLocation(officeLocationModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await OfficeLocationService.addOfficeLocation(officeLocationModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      } else {
        return false;
      }
    } catch (ex) {
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateOfficeLocation(OfficeLocationModel officeLocationModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateOfficeLocation(officeLocationModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await OfficeLocationService.updateOfficeLocation(officeLocationModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      } else {
        return false;
      }
    } catch (ex) {
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteOfficeLocation(OfficeLocationModel officeLocationModel) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await OfficeLocationService.deleteOfficeLocation(officeLocationModel.id);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      } else {
        return false;
      }
    } catch (ex) {
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  bool _validateOfficeLocation(OfficeLocationModel officeLocationModel) {
    if (officeLocationModel.name.trim().isEmpty) {
      setErrorMsg(Messages.errorOfficeNameEmpty);
      return false;
    } else if (officeLocationModel.latitude == 0 &&
        officeLocationModel.longitude == 0) {
      setErrorMsg(Messages.errorOfficeCoordinatesEmpty);
      return false;
    } else if (officeLocationModel.latitude < -90 ||
        officeLocationModel.latitude > 90) {
      setErrorMsg(Messages.errorOfficeLatitudeRange);
      return false;
    } else if (officeLocationModel.longitude < -180 ||
        officeLocationModel.longitude > 180) {
      setErrorMsg(Messages.errorOfficeLongitudeRange);
      return false;
    } else if (officeLocationModel.radiusMeters <= 0) {
      setErrorMsg(Messages.errorOfficeRadiusRange);
      return false;
    } else {
      return true;
    }
  }
}
