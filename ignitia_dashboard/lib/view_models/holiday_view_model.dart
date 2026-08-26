import 'package:ignitia_dashboard/models/dropdown_model.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/repo/holiday_services.dart';
import 'package:ignitia_dashboard/utils/message.dart';
import 'package:ignitia_dashboard/view_models/base_view_model.dart';

class HolidayViewModel extends BaseViewModel {
  HolidayViewModel() {
    getHolidayList();
  }

  List<DropDownModel> get holidayTypeDropDownItems => [
        DropDownModel(1, "Government"),
        DropDownModel(2, "Festival"),
        DropDownModel(3, "Weekend"),
        DropDownModel(4, "Other"),
      ];

  List<HolidayModel> _holidayList = [];
  List<HolidayModel> get holidayList => _holidayList;
  _setHolidayList(List<HolidayModel> list) {
    _holidayList = list;
    notifyListeners();
  }

  Future getHolidayList() async {
    setErrorMsg("");
    setLoading(true);

    var res = await HolidayService.getHolidayList();
    if (res is Success) {
      var data = res.response as List<HolidayModel>;
      _setHolidayList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future<bool> addHoliday(HolidayModel holidayModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateHoliday(holidayModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await HolidayService.addHoliday(holidayModel);
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

  Future<bool> updateHoliday(HolidayModel holidayModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateHoliday(holidayModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await HolidayService.updateHoliday(holidayModel);
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

  Future<bool> deleteHoliday(HolidayModel holidayModel) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await HolidayService.deleteHoliday(holidayModel.id);
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

  bool _validateHoliday(HolidayModel holidayModel) {
    if (holidayModel.holidayName.trim().isEmpty) {
      setErrorMsg(Messages.errorHolidayNameEmpty);
      return false;
    } else if (holidayModel.holidayType.trim().isEmpty) {
      setErrorMsg(Messages.errorHolidayTypeEmpty);
      return false;
    } else if (holidayModel.getEndDate().isBefore(holidayModel.getStartDate())) {
      setErrorMsg(Messages.errorHolidayDateRange);
      return false;
    } else {
      return true;
    }
  }
}
