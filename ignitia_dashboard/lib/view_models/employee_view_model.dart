import 'package:ignitia_dashboard/models/employee/employee_contact_info_model.dart';
import 'package:ignitia_dashboard/repo/employee_services.dart';
import 'package:ignitia_dashboard/view_models/base_view_model.dart';
import '../models/dropdown_model.dart';
import '../models/employee/employee_model.dart';
import '../repo/api_status.dart';

class EmployeeViewModel extends BaseViewModel {
  List<EmployeeModel> _employeeList = [];
  List<EmployeeModel> get employeeList => _employeeList;
  List<DropDownModel> _dropDownItems = [];
  List<DropDownModel> get dropDownItems => _dropDownItems;
  _setEmployeeList(List<EmployeeModel> list) {
    _employeeList.clear();
    _employeeList = list;
    dropDownItems.clear();
    list.forEach((e) {
      dropDownItems.add(DropDownModel(e.id, e.employeeName));
    });
    notifyListeners();
  }

  Future getEmployeeList() async {
    setErrorMsg("");
    setLoading(true);

    var res = await EmployeeService.getEmployeeList();
    if (res is Success) {
      var data = res.response as List<EmployeeModel>;
      _setEmployeeList(data);
      setLoading(false);
    } else if (res is Failed) {
      _employeeList.clear();
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future getContactInfo(int employeeId) async {
    setErrorMsg("");
    setLoading(true);

    var res = await EmployeeService.getContactInfo(employeeId);
    if (res is Success) {
      var data = res.response as EmployeeContactInfoModel?;
      setLoading(false);
      return data;
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
      return null;
    }
    notifyListeners();
  }

  void Clear() {
    _employeeList.clear();
    _dropDownItems.clear();
    notifyListeners();
  }
}
