import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holiday_model.g.dart';

@JsonSerializable()
class HolidayModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "holiday_name")
  String holidayName;

  @JsonKey(name: "holiday_type")
  String holidayType;

  @JsonKey(name: "start_date")
  String startDateUnformated;

  DateTime getStartDate() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(startDateUnformated);
    } catch (e) {
      try {
        return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(startDateUnformated);
      } catch (e) {
        return DateFormat("yyyy-MM-dd").parse(startDateUnformated);
      }
    }
  }

  String getStartDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getStartDate());
  }

  @JsonKey(name: "end_date")
  String endDateUnformated;

  DateTime getEndDate() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(endDateUnformated);
    } catch (e) {
      try {
        return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(endDateUnformated);
      } catch (e) {
        return DateFormat("yyyy-MM-dd").parse(endDateUnformated);
      }
    }
  }

  String getEndDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getEndDate());
  }

  int getTotalDays() {
    return getEndDate().difference(getStartDate()).inDays + 1;
  }

  HolidayModel({
    required this.holidayName,
    required this.holidayType,
    required this.startDateUnformated,
    required this.endDateUnformated,
    this.id = 0,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) =>
      _$HolidayModelFromJson(json);

  Map<String, dynamic> toJson() => _$HolidayModelToJson(this);
}
