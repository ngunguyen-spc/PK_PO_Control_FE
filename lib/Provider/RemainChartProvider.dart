// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:ma_visualization/Model/RemainChartModel.dart';
// import 'package:intl/intl.dart';
// import '../API/ApiService.dart';
//
// class RemainChartProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
//
//   List<RemainChartModel> _data = [];
//   String? _lastLoadedDateString;
//   String? _lastLoadedDiv;
//   bool _isLoading = false;
//
//   List<RemainChartModel> get data      => _data;
//   bool                   get isLoading => _isLoading;
//
//   DateTime _lastFetchedDate = DateTime.now();
//   String   _currentDiv      = '';
//   Timer?   _dailyTimer;
//   DateTime get lastFetchedDate => _lastFetchedDate;
//
//   // Thoi gian load lan cuoi (data ve)
//   DateTime? _lastLoadedTime;
//   DateTime? get lastLoadedTime => _lastLoadedTime;
//
//   // Thoi gian timer bat (countdown chinh xac)
//   DateTime? _lastReloadTriggeredAt;
//   DateTime? get nextLoadTime =>
//       _lastReloadTriggeredAt?.add(const Duration(minutes: 1));
//
//   RemainChartProvider() { _initTimer(); }
//
//   void _initTimer() {
//     _dailyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       if (_currentDiv.isNotEmpty) {
//         debugPrint('[Timer] Auto-reload chart — div=$_currentDiv date=$date');
//         _lastReloadTriggeredAt = DateTime.now();
//         // Reset cache check de force fetch, KHONG clearData tranh UI nhay
//         _lastLoadedDateString = null;
//         _lastLoadedDiv        = null;
//         notifyListeners(); // cap nhat nextLoadTime ngay lap tuc
//         fetchRemainChart(_currentDiv, date);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _dailyTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> fetchRemainChart(String div, String date) async {
//     if (_lastLoadedDiv == div &&
//         _lastLoadedDateString == date &&
//         _data.isNotEmpty) return;
//
//     _currentDiv = div;
//     _isLoading  = true;
//     notifyListeners();
//
//     final result = await _apiService.fetchRemainChart(div, date);
//
//     _data                 = result;
//     _lastLoadedDiv        = div;
//     _lastLoadedDateString = date;
//     _isLoading            = false;
//     _lastLoadedTime       = DateTime.now();
//     notifyListeners();
//   }
//
//   void clearData() {
//     _data                 = [];
//     _lastLoadedDateString = null;
//     _lastLoadedDiv        = null;
//     notifyListeners();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';

class RemainChartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RemainChartModel> _data = [];
  String? _lastLoadedDateString;
  String? _lastLoadedDiv;
  bool _isLoading = false;

  List<RemainChartModel> get data        => _data;
  bool get isLoading    => _isLoading && _data.isEmpty;
  bool get isRefreshing => _isLoading && _data.isNotEmpty;

  DateTime _lastFetchedDate = DateTime.now();
  String   _currentDiv      = '';
  Timer?   _dailyTimer;
  DateTime get lastFetchedDate => _lastFetchedDate;

  DateTime? _lastLoadedTime;
  DateTime? get lastLoadedTime => _lastLoadedTime;

  DateTime? _lastReloadTriggeredAt;
  DateTime? get nextLoadTime =>
      _lastReloadTriggeredAt?.add(const Duration(minutes: 1));

  RemainChartProvider() { _initTimer(); }

  void _initTimer() {
    _dailyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_currentDiv.isNotEmpty) {
        debugPrint('[${DateTime.now()}] [Timer] Auto-reload chart — div=$_currentDiv date=$date');
        _lastReloadTriggeredAt = DateTime.now();
        _lastLoadedDateString  = null;
        _lastLoadedDiv         = null;
        notifyListeners();
        fetchRemainChart(_currentDiv, date);
      }
    });
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchRemainChart(String div, String date) async {
    if (_lastLoadedDiv == div &&
        _lastLoadedDateString == date &&
        _data.isNotEmpty) return;

    _currentDiv            = div;
    _lastReloadTriggeredAt = DateTime.now();
    _isLoading             = true;
    notifyListeners();

    final result = await _apiService.fetchRemainChart(div, date);

    _lastLoadedDiv        = div;
    _lastLoadedDateString = date;
    _isLoading            = false;
    _lastLoadedTime       = DateTime.now();

    if (_dataHasChanged(result)) {
      _data = result;
      debugPrint('[${DateTime.now()}] [RemainChart] Data changed → notifyListeners');
    } else {
      debugPrint('[${DateTime.now()}] [RemainChart] Data unchanged → skip re-render');
    }

    notifyListeners(); // 1 lần duy nhất để tắt spinner
  }

  bool _dataHasChanged(List<RemainChartModel> newData) {
    if (newData.length != _data.length) return true;
    final oldSum = _data.fold<double>(0, (s, e) => s + e.remain_PO);
    final newSum = newData.fold<double>(0, (s, e) => s + e.remain_PO);
    if (oldSum != newSum) return true;
    for (int i = 0; i < newData.length; i++) {
      if (newData[i].date != _data[i].date ||
          newData[i].remain_PO != _data[i].remain_PO) return true;
    }
    return false;
  }

  void clearData() {
    _data                 = [];
    _lastLoadedDateString = null;
    _lastLoadedDiv        = null;
    notifyListeners();
  }
}