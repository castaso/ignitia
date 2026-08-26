// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalaryModel _$SalaryModelFromJson(Map<String, dynamic> json) => SalaryModel(
      json['employee_id'] as String,
      json['name'] as String,
      json['designation'] as String,
      json['email'] as String,
      json['joining_date'] as String,
      json['bank_name'] as String?,
      json['bank_account_no'] as String?,
      json['payment_mode'] as String,
      json['days_of_month'] as int,
      json['holidays'] as int,
      json['present_days'] as int,
      json['leave_days'] as int,
      json['absent_days'] as int,
      (json['basic_salary'] as num).toDouble(),
      (json['medical_allowance'] as num).toDouble(),
      (json['convenyence_allowance'] as num).toDouble(),
      (json['gross_salary'] as num).toDouble(),
      json['ot_hours'] as String?,
      (json['other_allowance'] as num).toDouble(),
      (json['bonus'] as num).toDouble(),
      json['other_allowance_description'] as String?,
      (json['overtime'] as num).toDouble(),
      (json['ot_amount'] as num).toDouble(),
      (json['absent_deduction'] as num).toDouble(),
      json['other_deduction_description'] as String?,
      (json['other_deduction'] as num).toDouble(),
      (json['ait'] as num).toDouble(),
      (json['net_pay'] as num).toDouble(),
      json['is_disbursed'] as int,
    );

Map<String, dynamic> _$SalaryModelToJson(SalaryModel instance) =>
    <String, dynamic>{
      'employee_id': instance.employeeId,
      'name': instance.employeeName,
      'designation': instance.designation,
      'email': instance.email,
      'joining_date': instance.joining_date_unformated,
      'bank_name': instance.bankName,
      'bank_account_no': instance.bankAccountNo,
      'payment_mode': instance.paymentMode,
      'days_of_month': instance.daysOfMonth,
      'holidays': instance.holidays,
      'present_days': instance.presentDays,
      'leave_days': instance.leaveDays,
      'absent_days': instance.absentDays,
      'basic_salary': instance.basicSalary,
      'medical_allowance': instance.medicalAllowance,
      'convenyence_allowance': instance.convenyenceAllowance,
      'gross_salary': instance.grossSalary,
      'ot_hours': instance.otHours,
      'other_allowance': instance.otherAllowance,
      'bonus': instance.bonus,
      'other_allowance_description': instance.otherAllowanceDescription,
      'overtime': instance.overtime,
      'ot_amount': instance.otAmount,
      'absent_deduction': instance.absentDeduction,
      'other_deduction_description': instance.otherDeductionDescription,
      'other_deduction': instance.otherDeduction,
      'ait': instance.ait,
      'net_pay': instance.netPay,
      'is_disbursed': instance.isDisbursed,
    };
