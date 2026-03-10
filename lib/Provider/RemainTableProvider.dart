import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:ma_visualization/Model/RepairFeeModel.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';

class RemainTableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RemainTableModel> _data = [];
  DateTime? _lastLoadedDate;
  String? _lastLoadedDateString;
  String? _lastLoadedDiv;
  bool _isLoading = false;

  List<RemainTableModel> get data => _data;
  bool get isLoading => _isLoading;
  RemainTableModel? selectedItem;

  DateTime _lastFetchedDate = DateTime.now();
  String _currentDiv = '';  // ✅ Lưu div hiện tại cho timer
  Timer? _dailyTimer;

  DateTime get lastFetchedDate => _lastFetchedDate;

  RemainTableProvider() {
    _initTimer();
  }

  void _initTimer() {
    _dailyTimer = Timer.periodic(const Duration(minutes: 60), (timer) {
      final now = DateTime.now();
      if (!_isSameDate(now, _lastFetchedDate)) {
        _lastFetchedDate = now;
        final date = DateFormat('yyyy-MM-dd').format(now);
        if (_currentDiv.isNotEmpty) {
          fetchRemainTable(_currentDiv, date); // ✅ Dùng div đã lưu
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

  // Future<void> fetchRemainTable(String month) async {
  //   final now = DateTime.now();
  //
  //   // Sửa điều kiện: nếu đã tải hôm nay VÀ cùng tháng thì không cần gọi lại
  //   if (_lastLoadedDate != null &&
  //       _lastLoadedMonth == month &&
  //       _lastLoadedDate!.day == now.day &&
  //       _lastLoadedDate!.month == now.month &&
  //       _lastLoadedDate!.year == now.year) {
  //     return;
  //   }
  //
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   final result = await _apiService.fetchRemainTable(month);
  //   _data = result;
  //   _lastLoadedDate = now;
  //   _lastLoadedMonth = month; // Cập nhật tháng
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<void> fetchRemainTable(String div, String date) async {
    // ✅ Cache check cả div lẫn date
    if (_lastLoadedDiv == div &&
        _lastLoadedDateString == date &&
        _data.isNotEmpty) return;

    _currentDiv = div;

    _isLoading = true;
    notifyListeners();

    final result = await _apiService.fetchRemainTable(div, date);

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
