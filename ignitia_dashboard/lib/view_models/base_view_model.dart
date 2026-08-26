import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier{

  bool _loading = false;
  String _errorMsg = "";

  bool get loading => _loading;
  String get errorMsg => _errorMsg;

  setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  setErrorMsg(String msg) {
    _errorMsg = msg;
    notifyListeners();
  }

  /*
  List<AllUserModel> _allUserList = [];
  List<AllUserModel> get allUserList => _allUserList;
  _setAllUserList(List<AllUserModel> list) async {
    _allUserList = list;
  }

  getAllUsers() async {
    var requestModel =
    BaseRequestModel(FieldValue.loginName, FieldValue.accessKey);
    var res = await HomeService.getAllUserList(requestModel);
    if (res is Success) {
      var data = res.response as List<AllUserModel>;
      _setAllUserList(data);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason as String);
    }
  }

  String getUserNameById(int id) {
    var user = _allUserList.firstWhere((element) => element.id == id);
    return user.name;
  }

   */
}