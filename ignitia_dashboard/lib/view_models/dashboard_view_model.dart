import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/models/task/task_model.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/repo/dashboard_services.dart';
import 'package:ignitia_dashboard/view_models/base_view_model.dart';

class DashboardViewModel extends BaseViewModel {
  // ---- Summary (top KPIs) ----
  Map<String, dynamic> _summary = {};
  Map<String, dynamic> get summary => _summary;

  // ---- Charts (all four metrics, rendered side-by-side per layout) ----
  Map<String, List<Map<String, dynamic>>> _charts = {};
  Map<String, List<Map<String, dynamic>>> get charts => _charts;
  List<Map<String, dynamic>> chartFor(String metric) => _charts[metric] ?? [];
  bool _chartLoading = false;
  bool get chartLoading => _chartLoading;

  // ---- Who's off ----
  int _whoIsOffDays = 1;
  int get whoIsOffDays => _whoIsOffDays;
  List<Map<String, dynamic>> _whoIsOff = [];
  List<Map<String, dynamic>> get whoIsOff => _whoIsOff;

  // ---- Contract & probation ----
  List<Map<String, dynamic>> _contractProbation = [];
  List<Map<String, dynamic>> get contractProbation => _contractProbation;

  // ---- Balance time off (unlimited balances hidden per spec) ----
  List<Map<String, dynamic>> _leaveBalance = [];
  List<Map<String, dynamic>> get leaveBalance =>
      _leaveBalance.where((r) => (r["entitlement"] as int? ?? 0) > 0).toList();

  // ---- Announcements ----
  List<Map<String, dynamic>> _announcements = [];
  String _announcementCategory = "ALL";
  String get announcementCategory => _announcementCategory;
  List<Map<String, dynamic>> get filteredAnnouncements {
    if (_announcementCategory == "ALL") return _announcements;
    return _announcements
        .where((a) => (a["audience"] ?? "") == _announcementCategory)
        .toList();
  }

  // ---- AI summary ----
  String _aiSummaryText = "";
  bool _aiSummaryLoading = false;
  String get aiSummaryText => _aiSummaryText;
  bool get aiSummaryLoading => _aiSummaryLoading;

  // ---- Tasks ----
  List<TaskModel> _tasks = [];
  bool _tasksLoading = false;
  List<TaskModel> get tasks => _tasks;
  bool get tasksLoading => _tasksLoading;

  // ---- Inbox badge ----
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // ---- Company ID (sidebar footer) ----
  String _companyCode = "";
  String get companyCode => _companyCode;

  int get pendingApprovalsTotal =>
      ((_summary["pending_overtime"] as int? ?? 0)) +
      ((_summary["pending_leave"] as int? ?? 0)) +
      ((_summary["pending_attendance_edit"] as int? ?? 0));

  Future<void> loadAll() async {
    await Future.wait([
      _loadSummary(),
      _loadCharts(),
      _loadWhoIsOff(),
      _loadContractProbation(),
      _loadLeaveBalance(),
      _loadAnnouncements(),
      _loadTasks(),
      _loadUnreadCount(),
      _loadCompany(),
    ]);
  }

  Future<void> _loadCompany() async {
    var res = await DashboardService.getCompanies();
    if (res is Success &&
        res.response is List &&
        (res.response as List).isNotEmpty) {
      final companies = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      final active =
          companies.where((c) => (c["status_id"] as int? ?? 1) == 1).toList();
      final pick = (active.isNotEmpty ? active : companies).first;
      final code = (pick["code"] ?? "").toString();
      _companyCode = code.isNotEmpty ? code : "${pick["id"]}";
      notifyListeners();
    }
  }

  Future<void> _loadSummary() async {
    var res = await DashboardService.getSummary();
    if (res is Success && res.response is Map) {
      _summary = (res.response as Map).cast<String, dynamic>();
      notifyListeners();
    }
  }

  static const List<String> chartMetrics = [
    "employment_status",
    "length_of_service",
    "job_level",
    "gender_diversity",
  ];

  Future<void> _loadCharts() async {
    _chartLoading = true;
    notifyListeners();
    final results = await Future.wait(
      chartMetrics.map((m) => DashboardService.getEmployeeChart(m)),
    );
    final next = <String, List<Map<String, dynamic>>>{};
    for (int i = 0; i < chartMetrics.length; i++) {
      final res = results[i];
      if (res is Success && res.response is List) {
        next[chartMetrics[i]] = (res.response as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    }
    _charts = next;
    _chartLoading = false;
    notifyListeners();
  }

  Future<void> refreshCharts() => _loadCharts();

  Future<void> _loadWhoIsOff() async {
    var res = await DashboardService.getWhoIsOff(_whoIsOffDays);
    if (res is Success && res.response is List) {
      _whoIsOff = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      notifyListeners();
    }
  }

  Future<bool> setWhoIsOffDays(int days) async {
    if (days == _whoIsOffDays) return true;
    _whoIsOffDays = days;
    await _loadWhoIsOff();
    return true;
  }

  Future<void> _loadContractProbation() async {
    var res = await DashboardService.getContractProbation(30);
    if (res is Success && res.response is List) {
      _contractProbation = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      notifyListeners();
    }
  }

  Future<void> _loadLeaveBalance() async {
    var res = await DashboardService.getLeaveSummary();
    if (res is Success && res.response is List) {
      _leaveBalance = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      notifyListeners();
    }
  }

  Future<void> _loadAnnouncements() async {
    var res = await DashboardService.getAnnouncements();
    if (res is Success && res.response is List) {
      _announcements = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      notifyListeners();
    }
  }

  Future<bool> setAnnouncementCategory(String category) async {
    if (category == _announcementCategory) return true;
    _announcementCategory = category;
    notifyListeners();
    return true;
  }

  Future<void> loadAiSummary() async {
    _aiSummaryLoading = true;
    notifyListeners();
    var res = await DashboardService.getAiSummary();
    if (res is Success && res.response is Map) {
      _aiSummaryText =
          ((res.response as Map)["text"] as String?) ?? "";
    }
    _aiSummaryLoading = false;
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    _tasksLoading = true;
    notifyListeners();
    var res = await DashboardService.getTasks();
    if (res is Success && res.response is List) {
      _tasks = (res.response as List)
          .whereType<Map>()
          .map((e) => TaskModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    _tasksLoading = false;
    notifyListeners();
  }

  Future<bool> addTask(TaskModel task) async {
    var res = await DashboardService.addTask(task);
    if (res is Success) {
      await _loadTasks();
      return true;
    }
    return false;
  }

  Future<bool> updateTask(TaskModel task) async {
    var res = await DashboardService.updateTask(task);
    if (res is Success) {
      await _loadTasks();
      return true;
    }
    return false;
  }

  Future<bool> deleteTask(int id) async {
    var res = await DashboardService.deleteTask(id);
    if (res is Success) {
      await _loadTasks();
      return true;
    }
    return false;
  }

  Future<void> _loadUnreadCount() async {
    var res = await DashboardService.getNotifications(0);
    if (res is Success && res.response is List) {
      _unreadCount = (res.response as List).length;
      notifyListeners();
    }
  }
}
