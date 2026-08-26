import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'salary_model.g.dart';

@JsonSerializable()
class SalaryModel {

  @JsonKey(name: "employee_id")
  String employeeId;

  @JsonKey(name: "name")
  String employeeName;

  @JsonKey(name: "designation")
  String designation;

  @JsonKey(name: "email")
  String email;

  @JsonKey(name: "joining_date")
  String joining_date_unformated;

  DateTime getJoiningDate() {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(joining_date_unformated!);

  }

  String getJoiningDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getJoiningDate()!);

  }

  @JsonKey(name: "bank_name")
  String? bankName;

  @JsonKey(name: "bank_account_no")
  String? bankAccountNo;

  @JsonKey(name: "payment_mode")
  String paymentMode;

  @JsonKey(name: "days_of_month")
  int daysOfMonth;

  @JsonKey(name: "holidays")
  int holidays;

  @JsonKey(name: "present_days")
  int presentDays;

  @JsonKey(name: "leave_days")
  int leaveDays;

  @JsonKey(name: "absent_days")
  int absentDays;

  @JsonKey(name: "basic_salary")
  double basicSalary;

  double get houseRent => grossSalary - (basicSalary + medicalAllowance + convenyenceAllowance);

  @JsonKey(name: "medical_allowance")
  double medicalAllowance;

  @JsonKey(name: "convenyence_allowance")
  double convenyenceAllowance;

  @JsonKey(name: "gross_salary")
  double grossSalary;

  @JsonKey(name: "ot_hours")
  String? otHours;

  @JsonKey(name: "other_allowance")
  double otherAllowance;

  @JsonKey(name: "bonus")
  double bonus;

  @JsonKey(name: "other_allowance_description")
  String? otherAllowanceDescription;

  @JsonKey(name: "overtime")
  double overtime;

  @JsonKey(name: "ot_amount")
  double otAmount;

  @JsonKey(name: "absent_deduction")
  double absentDeduction;

  @JsonKey(name: "other_deduction_description")
  String? otherDeductionDescription;

  @JsonKey(name: "other_deduction")
  double otherDeduction;

  @JsonKey(name: "ait")
  double ait;

  @JsonKey(name: "net_pay")
  double netPay;

  @JsonKey(name: "is_disbursed")
  int isDisbursed;

  SalaryModel(
      this.employeeId,
      this.employeeName,
      this.designation,
      this.email,
      this.joining_date_unformated,
      this.bankName,
      this.bankAccountNo,
      this.paymentMode,
      this.daysOfMonth,
      this.holidays,
      this.presentDays,
      this.leaveDays,
      this.absentDays,
      this.basicSalary,
      this.medicalAllowance,
      this.convenyenceAllowance,
      this.grossSalary,
      this.otHours,
      this.otherAllowance,
      this.bonus,
      this.otherAllowanceDescription,
      this.overtime,
      this.otAmount,
      this.absentDeduction,
      this.otherDeductionDescription,
      this.otherDeduction,
      this.ait,
      this.netPay,
      this.isDisbursed);

  factory SalaryModel.fromJson(Map<String, dynamic> json) =>
      _$SalaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalaryModelToJson(this);
}