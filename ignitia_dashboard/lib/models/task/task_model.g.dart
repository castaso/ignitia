// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String,
  description: json['description'] as String?,
  assignedEmployeeId: (json['assigned_employee_id'] as num?)?.toInt(),
  assignedBy: (json['assigned_by'] as num?)?.toInt(),
  dueDate: json['due_date'] as String?,
  status: json['status'] as String? ?? "Open",
  assigneeName: json['assignee_name'] as String? ?? '',
  createdByName: json['created_by_name'] as String? ?? '',
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'assigned_employee_id': instance.assignedEmployeeId,
  'assigned_by': instance.assignedBy,
  'due_date': instance.dueDate,
  'status': instance.status,
  'assignee_name': instance.assigneeName,
  'created_by_name': instance.createdByName,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
