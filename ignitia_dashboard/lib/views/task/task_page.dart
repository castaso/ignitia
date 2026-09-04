import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/models/task/task_model.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/view_models/employee_view_model.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

/// Task management (spec item 17): assign tasks to employees.
class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  int? _assigneeId;
  String _status = Strings.taskStatusOpen;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      _dueDateController.text = DateFormat("yyyy-MM-dd").format(picked);
    }
  }

  Future<void> _save() async {
    final viewModel = context.read<DashboardViewModel>();
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title is required.")),
      );
      return;
    }
    final task = TaskModel(
      id: 0,
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      assignedEmployeeId: _assigneeId,
      dueDate:
          _dueDateController.text.trim().isEmpty ? null : _dueDateController.text.trim(),
      status: _status,
    );
    final ok = await viewModel.addTask(task);
    if (ok && mounted) {
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      setState(() => _assigneeId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task created.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    final viewModel = context.watch<DashboardViewModel>();
    final employees = context.watch<EmployeeViewModel>().employeeList;

    return Scaffold(
      appBar: CustomAppBar(
        title: Strings.textTask,
        actions: [
          IconButton(
            tooltip: Strings.btnTextAddTask,
            icon: const Icon(Icons.add_task),
            onPressed: () => openAddTaskDialog(context),
          ),
        ],
      ),
      body: Row(
        children: [
          mediaSize.width > webWidth
              ? Flexible(flex: 1, child: MenuPage())
              : Container(),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: viewModel.tasksLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.tasks.isEmpty
                      ? const Center(
                          child: TitleTextView(
                            Strings.textEmpty,
                            textAlign: TextAlign.center,
                            textColor: subTitleTextColor,
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.tasks.length,
                          itemBuilder: (context, index) {
                            final task = viewModel.tasks[index];
                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    _StatusDot(status: task.status),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TitleTextView(task.title,
                                              textSize: 14),
                                          if ((task.description ?? "")
                                              .isNotEmpty)
                                            TitleTextView(
                                              task.description!,
                                              textSize: 12,
                                              fontFamily: Fonts.gilroy_regular,
                                              textColor: subTitleTextColor,
                                              maxLines: 2,
                                            ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (task.assigneeName.isNotEmpty) ...[
                                                Icon(Icons.person_outline,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                TitleTextView(task.assigneeName,
                                                    textSize: 11,
                                                    fontFamily: Fonts.gilroy_regular,
                                                    textColor: Colors.grey),
                                                const SizedBox(width: 12),
                                              ],
                                              if (task.dueDate != null &&
                                                  task.dueDate!.isNotEmpty) ...[
                                                Icon(Icons.event,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                TitleTextView(task.dueDate!,
                                                    textSize: 11,
                                                    fontFamily: Fonts.gilroy_regular,
                                                    textColor: Colors.grey),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      tooltip: Strings.textTaskStatus,
                                      icon: const Icon(
                                          Icons.more_vert, size: 20),
                                      onSelected: (value) async {
                                        await viewModel
                                            .updateTask(TaskModel(
                                                id: task.id,
                                                title: task.title,
                                                status: value));
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                            value: Strings.taskStatusOpen,
                                            child: Text(Strings.taskStatusOpen)),
                                        const PopupMenuItem(
                                            value: Strings.taskStatusInProgress,
                                            child: Text(Strings.taskStatusInProgress)),
                                        const PopupMenuItem(
                                            value: Strings.taskStatusDone,
                                            child: Text(Strings.taskStatusDone)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  void openAddTaskDialog(BuildContext context) {
    final employees =
        Provider.of<EmployeeViewModel>(context, listen: false).employeeList;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: TitleTextView(Strings.btnTextAddTask, textSize: 16),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: Strings.textTaskTitle),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: Strings.textTaskDescription),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _assigneeId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: Strings.textTaskAssignee),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text("—")),
                    for (final e in employees)
                      DropdownMenuItem<int?>(
                          value: e.id,
                          child: Text(e.employeeName,
                              overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => _assigneeId = value),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: Strings.textTaskDueDate,
                        border: OutlineInputBorder()),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dueDateController.text.isEmpty
                                ? "Select a date"
                                : _dueDateController.text,
                            style: TextStyle(
                                color: _dueDateController.text.isEmpty
                                    ? Colors.grey
                                    : titleTextColor),
                          ),
                        ),
                        const Icon(Icons.event, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(Strings.btnTextCancel),
            ),
            TextButton(onPressed: _save, child: const Text(Strings.btnTextOk)),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == Strings.taskStatusDone
        ? successColor
        : status == Strings.taskStatusInProgress
            ? blYellowColor
            : kPrimaryLightColor;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
