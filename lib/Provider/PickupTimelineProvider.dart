// lib/Provider/PickupTimelineProvider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ma_visualization/API/ApiService.dart';
import 'package:ma_visualization/Model/PickupTimelineModel.dart';

class PickupTimelineProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PickupTimelineModel> _data = [];
  String? _lastLoadedDiv;
  String? _lastLoadedDate;
  bool _isLoading = false;

  String _currentDiv  = '';
  String _currentDate = '';
  DateTime _lastReloadTriggeredAt = DateTime.now();
  Timer? _timer;

  List<PickupTimelineModel> get data        => _data;
  bool get isLoading    => _isLoading && _data.isEmpty;
  bool get isRefreshing => _isLoading && _data.isNotEmpty;
  DateTime get lastReloadTriggeredAt => _lastReloadTriggeredAt;

  PickupTimelineProvider() {
    _initTimer();
  }

  void _initTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_currentDiv.isNotEmpty && _currentDate.isNotEmpty) {
        _lastLoadedDiv  = null;
        _lastLoadedDate = null;
        fetchPickupTimeline(_currentDiv, _currentDate);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPickupTimeline(String div, String date) async {
    if (_lastLoadedDiv == div && _lastLoadedDate == date && _data.isNotEmpty) return;

    _currentDiv  = div;
    _currentDate = date;
    _lastReloadTriggeredAt = DateTime.now();
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.fetchPickupTimeline(div, date);
    // result.sort((a, b) => a.pickupTime.compareTo(b.pickupTime));

    _data           = result;
    _lastLoadedDiv  = div;
    _lastLoadedDate = date;
    _isLoading      = false;
    notifyListeners();
  }

  void clearData() {
    _data           = [];
    _lastLoadedDiv  = null;
    _lastLoadedDate = null;
    notifyListeners();
  }
}