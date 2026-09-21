// lib/Provider/PickupTimelineProvider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ma_visualization/API/ApiService.dart';
import 'package:ma_visualization/Model/PickupTimelineModel.dart';

import '../Model/RemainTableDetailIDModel.dart';
import '../Model/RemainTableDetailModel.dart';

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

  // ── Cache PO  ────────────────────────────────────────────────────────────
  Map<String, List<RemainTableDetailModel>> _detailCache = {};
  bool _isDetailLoading = false;
  bool get isDetailReady => _detailCache.isNotEmpty;

  List<RemainTableDetailModel> getDetail(String cusID, String shipBy) =>
      _detailCache['$cusID|$shipBy'] ?? [];

  // ── Cache ID ──────────────────────────────────────────────────────────────
  Map<String, List<RemainTableDetailIDModel>> _detailCacheID = {};
  bool _isDetailIDLoading = false;

  List<RemainTableDetailIDModel> getDetailID(String cusID, String shipBy) {
    const allKey = 'All|All';
    if (!_detailCacheID.containsKey(allKey)) return [];
    if (cusID == 'All' && shipBy == 'All') return _detailCacheID[allKey]!;
    final poRows   = _detailCache['$cusID|$shipBy'] ?? [];
    final vbelnSet = poRows.map((r) => r.vbeln).toSet();
    return _detailCacheID[allKey]!
        .where((r) => vbelnSet.contains(r.vbeln))
        .toList();
  }

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

    _lastLoadedDiv  = div;
    _lastLoadedDate = date;
    _isLoading      = false;

    // ✅ So sánh data — chỉ update + prefetch nếu thực sự thay đổi
    if (_dataHasChanged(result)) {
      _data = result;
      debugPrint('[${DateTime.now()}] [PickupTimeline] Data changed → notifyListeners');
      _prefetchDetail(div, date); // reload detail cache khi data mới
    } else {
      debugPrint('[${DateTime.now()}] [PickupTimeline] Data unchanged → skip re-render');
    }

    notifyListeners(); // 1 lần duy nhất để tắt loading spinner
  }

  bool _dataHasChanged(List<PickupTimelineModel> newData) {
    if (newData.length != _data.length) return true;
    final oldSum = _data.fold<double>(0, (s, e) => s + e.remainPO);
    final newSum = newData.fold<double>(0, (s, e) => s + e.remainPO);
    if (oldSum != newSum) return true;
    for (int i = 0; i < newData.length; i++) {
      if (newData[i].cusID != _data[i].cusID ||
          newData[i].remainPO != _data[i].remainPO) return true;
    }
    return false;
  }

  // ── Prefetch all detail, group by cusID|shipBy ───────────────────────────
  Future<void> _prefetchDetail(String div, String date) async {
    if (_isDetailLoading) return;
    _isDetailLoading = true;
    debugPrint('[${DateTime.now()}] [Cache] Prefetching detail — div=$div date=$date');

    try {
      final all = await _apiService.fetchRemainTableDetailMTD(div, date, 'All', 'All');

      final Map<String, List<RemainTableDetailModel>> grouped = {};
      for (final row in all) {
        final key = '${row.cusID}|${row.shipBy}';
        grouped.putIfAbsent(key, () => []).add(row);
      }
      grouped['All|All'] = all;

      _detailCache = grouped;
      debugPrint('[${DateTime.now()}] [Cache] Done — ${all.length} rows, ${grouped.length} keys');
    } catch (e) {
      debugPrint('[${DateTime.now()}] [Cache] Prefetch failed: $e');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _data           = [];
    _lastLoadedDiv  = null;
    _lastLoadedDate = null;
    _detailCache    = {};
    _detailCacheID  = {};
    notifyListeners();
  }
}