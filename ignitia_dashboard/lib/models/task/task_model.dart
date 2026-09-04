import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "title")
  String title;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "assigned_employee_id")
  int? assignedEmployeeId;

  @JsonKey(name: "assigned_by")
  int? assignedBy;

  @JsonKey(name: "due_date")
  String? dueDate;

  @JsonKey(name: "status")
  String status; // Open / InProgress / Done

  @JsonKey(name: "assignee_name", defaultValue: "")
  String assigneeName;

  @JsonKey(name: "created_by_name", defaultValue: "")
  String createdByName;

  @JsonKey(name: "created_at")
  String? createdAt;

  @JsonKey(name: "updated_at")
  String? updatedAt;

  TaskModel({
    this.id = 0,
    required this.title,
    this.description,
    this.assignedEmployeeId,
    this.assignedBy,
    this.dueDate,
    this.status = "Open",
    this.assigneeName = "",
    this.createdByName = "",
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
