
import 'package:json_annotation/json_annotation.dart';

import '../../utils/string.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel{

  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "name")
  String employeeName;

  @JsonKey(name: "designation")
  String designation;

  @JsonKey(name: "cell_no")
  String? cellNo;

  @JsonKey(name: "email")
  String email;

  @JsonKey(name: "address")
  String? presentAddress;

  @JsonKey(name: "nid")
  String? nid;

  @JsonKey(name: "type_id")
  int typeId;

  @JsonKey(name: "employee_id")
  String employeeId;

  @JsonKey(name: "supervisor_id")
  int supervisorId;

  @JsonKey(name: "status_id")
  int statusId;

  @JsonKey(name: "joining_date")
  DateTime joiningDate;

  @JsonKey(name: "permanent_date")
  DateTime? permanentDate;

  // Attendance geo-restriction policy of the employee:
  //  - "Office"    -> attendance only inside the assigned office / branch fences
  //  - "Home"      -> attendance only inside the employee home geo-fence
  //  - "Anywhere"  -> no geo-restriction, attendance from any location
  @JsonKey(name: "attendance_location_type", defaultValue: "Office")
  String attendanceLocationType;

  @JsonKey(name: "home_latitude")
  double? homeLatitude;

  @JsonKey(name: "home_longitude")
  double? homeLongitude;

  @JsonKey(name: "home_radius_meters")
  double? homeRadiusMeters;

  String getIsActiveAsString() {
    return statusId == 1 ? Strings.yes : Strings.no;
  }

  bool get isHomeBasedAttendance =>
      attendanceLocationType.toLowerCase() ==
      Strings.attendanceLocationTypeHome.toLowerCase();

  bool get isAnywhereAttendance =>
      attendanceLocationType.toLowerCase() ==
      Strings.attendanceLocationTypeAnywhere.toLowerCase();

  String getAttendanceLocationAsString() {
    if (attendanceLocationType.isEmpty) {
      return Strings.attendanceLocationTypeOffice;
    }
    return attendanceLocationType;
  }

  EmployeeModel(
      this.id,
      this.employeeName,
      this.designation,
      this.cellNo,
      this.email,
      this.presentAddress,
      this.nid,
      this.typeId,
      this.employeeId,
      this.supervisorId,
      this.statusId,
      this.joiningDate,
      this.permanentDate,
      {this.attendanceLocationType = "Office",
      this.homeLatitude,
      this.homeLongitude,
      this.homeRadiusMeters});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);
}