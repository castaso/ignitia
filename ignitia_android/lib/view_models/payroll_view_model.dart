import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:i_employment/models/payroll/payslip_model.dart';
import 'package:i_employment/repo/payroll_services.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import 'package:intl/intl.dart';

import '../models/attendance/attendance_model.dart';
import '../models/attendance/user_attendance_summary_model.dart';
import '../models/payroll/salary_model.dart';
import '../repo/api_status.dart';
import '../repo/attendance_services.dart';
import '../repo/location_service.dart';
import '../utils/common_functions.dart';
import '../utils/global_fields.dart';

class PayrollViewModel extends BaseViewModel {
  // User home salary
  List<SalaryModel> _salaryList = [];
  List<SalaryModel> get salaryList => _salaryList;
  _setSalaryModelList(List<SalaryModel> list) {
    _salaryList.clear();
    _salaryList = list;
    notifyListeners();
  }

  List<PayslipModel> _payslip = [];
  List<PayslipModel> get payslip => _payslip;
  _setPayslip(SalaryModel? salaryModel) {
    _payslip.clear();
    if(salaryModel==null) return;
    _payslip.add(PayslipModel("Employee Id", salaryModel.employeeId));
    _payslip.add(PayslipModel("Employee Name", salaryModel.employeeName));
    _payslip.add(PayslipModel("Designation", salaryModel.designation));
    _payslip.add(PayslipModel("Joining Date", salaryModel.getJoiningDateAsString()));
    _payslip.add(PayslipModel("Bank Name", salaryModel.bankName??""));
    _payslip.add(PayslipModel("Account Number", salaryModel.bankAccountNo??""));
    _payslip.add(PayslipModel("Payment Method", salaryModel.paymentMode));
    _payslip.add(PayslipModel("Total Days", salaryModel.daysOfMonth.toString()));
    _payslip.add(PayslipModel("W/H Days", salaryModel.holidays.toString()));
    _payslip.add(PayslipModel("Present Days", salaryModel.presentDays.toString()));
    _payslip.add(PayslipModel("Leave Days", salaryModel.leaveDays.toString()));
    _payslip.add(PayslipModel("Absent Days", salaryModel.absentDays.toString()));
    _payslip.add(PayslipModel("Basic Salary", salaryModel.basicSalary.toString()));
    _payslip.add(PayslipModel("House Rent", salaryModel.houseRent.toString()));
    _payslip.add(PayslipModel("Medical Allowance", salaryModel.medicalAllowance.toString()));
    _payslip.add(PayslipModel("Convenience", salaryModel.convenyenceAllowance.toString()));
    _payslip.add(PayslipModel("Other Allowance Desc.", salaryModel.otherAllowanceDescription??""));
    _payslip.add(PayslipModel("Other Allowance", salaryModel.otherAllowance.toString()));
    _payslip.add(PayslipModel("Bonus", salaryModel.bonus.toString()));
    _payslip.add(PayslipModel("Overtime Hours", salaryModel.otHours??""));
    _payslip.add(PayslipModel("Overtime Amount", salaryModel.otAmount.toString()));
    _payslip.add(PayslipModel("Absent Deduction", salaryModel.absentDeduction.toString()));
    _payslip.add(PayslipModel("Other Deduction Desc.", salaryModel.otherDeductionDescription??""));
    _payslip.add(PayslipModel("Other Deduction", salaryModel.otherDeduction.toString()));
    _payslip.add(PayslipModel("AIT", salaryModel.ait.toString()));
    _payslip.add(PayslipModel("Net Pay", salaryModel.netPay.toString()));
    notifyListeners();
  }

  Future getPayslip(int year, int month) async {
    setErrorMsg("");
    setLoading(true);

    var res = await PayrollService.getPayslip(year, month);
    if (res is Success) {
      var data = res.response as SalaryModel?;
      _setPayslip(data);
      setLoading(false);
    } else if (res is Failed) {
      _payslip.clear();
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

}
