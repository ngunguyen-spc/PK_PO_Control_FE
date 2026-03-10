import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';

class RemainChartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RemainChartModel> _data = [];
  String? _lastLoadedDateString;
  String? _lastLoadedDiv; // ✅ Thêm cache div
  bool _isLoading = false;

  List<RemainChartModel> get data => _data;
  bool get isLoading => _isLoading;

  DateTime _lastFetchedDate = DateTime.now();
  String _currentDiv = '';  // ✅ Lưu div hiện tại cho timer
  String _currentDate = ''; // ✅ Lưu date hiện tại cho timer
  Timer? _dailyTimer;
  DateTime get lastFetchedDate => _lastFetchedDate;

  RemainChartProvider() {
    _initTimer();
  }

  void _initTimer() {
    _dailyTimer = Timer.periodic(const Duration(minutes: 60), (timer) {
      final now = DateTime.now();
      if (!_isSameDate(now, _lastFetchedDate)) {
        _lastFetchedDate = now;
        final date = DateFormat('yyyy-MM-dd').format(now);
        if (_currentDiv.isNotEmpty) {
          fetchRemainChart(_currentDiv, date); // ✅ Dùng div đã lưu
        }
      }
    });
    }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchRemainChart(String div, String date) async {
    // Nếu cùng date thì không gọi lại
    if (_lastLoadedDiv == div &&
        _lastLoadedDateString == date &&
        _data.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    // ✅ Gọi API riêng cho chart — truyền date, backend tính -7/+24
    final result = await _apiService.fetchRemainChart(div, date);

    _data = result;
    _lastLoadedDiv = div;
    _lastLoadedDateString = date;
    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _data = [];
    _lastLoadedDateString = null;
    _lastLoadedDiv = null;
    notifyListeners();
  }
}