import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'overtime_model.g.dart';

@JsonSerializable()
class OvertimeModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "employeE_ID")
  int employeeId;

  @JsonKey(name: "overtimE_DATE")
  String
      overtimeDateUnformated; //This data is not well format, so it is only use for data receive from API. Using of it may occur error
  DateTime getDateTime() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(overtimeDateUnformated);
    } catch (e) {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(overtimeDateUnformated);
    }
  }

  String getDateTimeAsString() {
    return DateFormat("dd/MM/yyyy").format(getDateTime());
  }

  @JsonKey(name: "checK_IN")
  String
      checkInUnformated; //This data is not well format, so it is only use for data receive from API. Using of it may occur error
  DateTime getCheckIn() {
    return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(checkInUnformated);
  }

  String getCheckInAsString() {
    return DateFormat("hh:mm a").format(getCheckIn());
  }

  @JsonKey(name: "checK_OUT")
  String
      checkOutUnformated; //This data is not well format, so it is only use for data receive from API. Using of it may occur error
  DateTime getCheckOut() {
    return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(checkOutUnformated!);
  }

  String getCheckOutAsString() {
    return DateFormat("hh:mm a").format(getCheckOut()!);
  }

  @JsonKey(name: "overtimE_MINUTES")
  int overtimeMinutes;

  @JsonKey(name: "status")
  String status;

  @JsonKey(name: "reason")
  String reason;

  @JsonKey(name: "supervisoR_ID")
  int? supervisorID;

  @JsonKey(name: "name")
  String? employeeName;

  @JsonKey(name: "designation")
  String? designation;

  OvertimeModel(
      {required this.id,
      required this.employeeId,
      required this.overtimeDateUnformated,
      required this.checkInUnformated,
      required this.checkOutUnformated,
      required this.overtimeMinutes,
      required this.status,
      required this.reason,
      this.supervisorID,
      this.employeeName,
      this.designation});

  factory OvertimeModel.fromJson(Map<String, dynamic> json) =>
      _$OvertimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeModelToJson(this);
}
