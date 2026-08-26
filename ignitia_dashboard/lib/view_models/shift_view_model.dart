import 'package:ignitia_dashboard/models/shift/employee_shift_assign_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/repo/shift_services.dart';
import 'package:ignitia_dashboard/utils/message.dart';
import 'package:ignitia_dashboard/view_models/base_view_model.dart';

class ShiftViewModel extends BaseViewModel {
  List<ShiftModel> _shiftList = [];
  List<ShiftModel> get shiftList => _shiftList;
  _setShiftList(List<ShiftModel> list) {
    _shiftList.clear();
    _shiftList = list;
    notifyListeners();
  }

  void Clear() {
    _shiftList.clear();
    notifyListeners();
  }

  Future getShiftList() async {
    setErrorMsg("");
    setLoading(true);

    var res = await ShiftService.getShiftList();
    if (res is Success) {
      var data = res.response as List<ShiftModel>;
      _setShiftList(data);
      setLoading(false);
    } else if (res is Failed) {
      _shiftList.clear();
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  bool _validateShiftForEdit(ShiftModel shiftModel) {
    if (shiftModel.shiftName.trim().isEmpty) {
      setErrorMsg(Messages.errorShiftNameEmpty);
      return false;
    }
    if (_parseTime(shiftModel.startTime).isAfter(_parseTime(shiftModel.endTime))) {
      setErrorMsg(Messages.errorShiftTimeRange);
      return false;
    }
    return true;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(2000, 1, 1, hour, minute);
  }

  Future<bool> addShift(ShiftModel shiftModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateShiftForEdit(shiftModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await ShiftService.addShift(shiftModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res;
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

  Future<bool> updateShift(ShiftModel shiftModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateShiftForEdit(shiftModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await ShiftService.updateShift(shiftModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res;
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

  Future<bool> deleteShift(int shiftId) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await ShiftService.deleteShift(shiftId);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res;
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

  bool _validateAssignForEdit(EmployeeShiftAssignModel assignModel) {
    if (assignModel.shiftId <= 0) {
      setErrorMsg(Messages.errorShiftSelectionEmpty);
      return false;
    }
    if (assignModel.employeeIds.isEmpty) {
      setErrorMsg(Messages.errorEmployeeSelectionEmpty);
      return false;
    }
    if (_parseDate(assignModel.endDate).isBefore(_parseDate(assignModel.startDate))) {
      setErrorMsg(Messages.errorShiftDateRange);
      return false;
    }
    return true;
  }

  DateTime _parseDate(String date) {
    final parts = date.split("-");
    final year = int.tryParse(parts[0]) ?? 0;
    final month = parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) : 1;
    final day = parts.length > 2 ? (int.tryParse(parts[2]) ?? 1) : 1;
    return DateTime(year, month, day);
  }

  Future<bool> assignShift(EmployeeShiftAssignModel assignModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateAssignForEdit(assignModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await ShiftService.assignShift(assignModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res;
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
}
