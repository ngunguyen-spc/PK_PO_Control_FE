import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
import 'package:ma_visualization/Model/RemainTableDetailIDModel.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';

class RemainTableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ── Summary ───────────────────────────────────────────────────────────────
  List<RemainTableModel> _data = [];
  String? _lastLoadedDateString;
  String? _lastLoadedDiv;
  bool _isLoading = false;

  List<RemainTableModel> get data        => _data;
  bool get isLoading    => _isLoading && _data.isEmpty;
  bool get isRefreshing => _isLoading && _data.isNotEmpty;

  // ── Cache PO (MTD) ────────────────────────────────────────────────────────
  Map<String, List<RemainTableDetailModel>> _detailCache = {};
  bool _isDetailLoading = false;
  Completer<void>? _detailLoadCompleter;

  // ── Cache ID (MTD_ID) — lazy load khi user toggle tab ID ──────────────────
  Map<String, List<RemainTableDetailIDModel>> _detailCacheID = {};
  bool _isDetailIDLoading = false;
  Completer<void>? _detailIDLoadCompleter;

  bool get isDetailIDLoading => _isDetailIDLoading;

  // ── Timer ─────────────────────────────────────────────────────────────────
  String    _currentDiv  = '';
  String    _currentDate = '';
  Timer?    _dailyTimer;
  DateTime? _lastLoadedTime;
  DateTime? _lastReloadTriggeredAt;

  DateTime? get lastLoadedTime        => _lastLoadedTime;
  DateTime? get lastReloadTriggeredAt => _lastReloadTriggeredAt;
  DateTime? get nextLoadTime =>
      _lastReloadTriggeredAt?.add(const Duration(minutes: 1));

  RemainTableProvider() { _initTimer(); }

  void _initTimer() {
    _dailyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_currentDiv.isNotEmpty) {
        _lastReloadTriggeredAt = DateTime.now();
        _lastLoadedDateString  = null;
        _lastLoadedDiv         = null;
        _detailCache           = {};
        _detailCacheID         = {};
        _detailLoadCompleter   = null;
        _detailIDLoadCompleter = null;
        notifyListeners();
        fetchRemainTable(_currentDiv, date);
      }
    });
  }

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  // ── Fetch summary ─────────────────────────────────────────────────────────
  Future<void> fetchRemainTable(String div, String date) async {
    if (_lastLoadedDiv == div &&
        _lastLoadedDateString == date &&
        _data.isNotEmpty) return;

    _currentDiv            = div;
    _currentDate           = date;
    _lastReloadTriggeredAt = DateTime.now();
    _isLoading             = true;
    notifyListeners();

    final result = await _apiService.fetchRemainTable(div, date);

    _lastLoadedDiv        = div;
    _lastLoadedDateString = date;
    _isLoading            = false;
    _lastLoadedTime       = DateTime.now();

    if (_dataHasChanged(result)) {
      _data = result;
      _prefetchDetail(div, date);
    }

    notifyListeners();
  }

  bool _dataHasChanged(List<RemainTableModel> newData) {
    if (newData.length != _data.length) return true;
    final oldSum = _data.fold<double>(0, (s, e) => s + e.remain_PO + e.remain_Qty);
    final newSum = newData.fold<double>(0, (s, e) => s + e.remain_PO + e.remain_Qty);
    if (oldSum != newSum) return true;
    for (int i = 0; i < newData.length; i++) {
      if (newData[i].cusID     != _data[i].cusID    ||
          newData[i].remain_PO != _data[i].remain_PO) return true;
    }
    return false;
  }

  // ── Prefetch PO detail (MTD) ──────────────────────────────────────────────
  Future<void> _prefetchDetail(String div, String date) async {
    if (_isDetailLoading) return;

    _detailLoadCompleter = Completer<void>();
    _isDetailLoading     = true;

    try {
      final all = await _apiService.fetchRemainTableDetailMTD(
          div, date, 'All', 'All');
      final grouped = <String, List<RemainTableDetailModel>>{};
      for (final row in all) {
        grouped.putIfAbsent('${row.cusID}|${row.shipBy}', () => []).add(row);
      }
      grouped['All|All'] = all;
      _detailCache = grouped;
      debugPrint('[Cache-PO] Done — ${all.length} rows, ${grouped.length} keys');
    } catch (e) {
      debugPrint('[Cache-PO] Failed: $e');
    } finally {
      _isDetailLoading = false;
      if (!(_detailLoadCompleter?.isCompleted ?? true)) {
        _detailLoadCompleter!.complete();
      }
      notifyListeners();
    }
  }

  // ── Public: fetch PO detail (cache-first, chờ prefetch nếu chưa xong) ────
  Future<List<RemainTableDetailModel>> fetchDetail({
    required String div,
    required String date,
    required String cusID,
    required String shipBy,
  }) async {
    // Nếu cache trống VÀ đang prefetch → chờ xong
    if (_detailCache.isEmpty && _isDetailLoading && _detailLoadCompleter != null) {
      debugPrint('[Cache-PO] Waiting for prefetch...');
      await _detailLoadCompleter!.future;
    }

    const allKey = 'All|All';
    if (_detailCache.containsKey(allKey)) {
      final all = _detailCache[allKey]!;
      if (cusID == 'All' && shipBy == 'All') return all;
      return all.where((r) => r.cusID == cusID && r.shipBy == shipBy).toList();
    }

    // Cache hoàn toàn trống (prefetch thất bại) → fallback API
    debugPrint('[Cache-PO] Miss — fallback API');
    return await _apiService.fetchRemainTableDetailMTD(div, date, cusID, shipBy);
  }

  // ── Public: fetch ID detail — lazy load ───────────────────────────────────
  Future<List<RemainTableDetailIDModel>> fetchDetailID({
    required String div,
    required String date,
    required String cusID,
    required String shipBy,
  }) async {
    final cacheKey = '$div|$date';

    // Cache hit → trả về ngay
    if (_detailCacheID.containsKey(cacheKey)) {
      final all = _detailCacheID[cacheKey]!;
      return _filterID(all, cusID, shipBy);
    }

    // Đang fetch → chờ completer
    if (_isDetailIDLoading && _detailIDLoadCompleter != null) {
      debugPrint('[Cache-ID] Already loading, waiting once...');
      await _detailIDLoadCompleter!.future;
      if (_detailCacheID.containsKey(cacheKey)) {
        return _filterID(_detailCacheID[cacheKey]!, cusID, shipBy);
      }
      return [];
    }

    // Chưa có cache, chưa loading → fetch lần đầu
    _detailIDLoadCompleter = Completer<void>();
    _isDetailIDLoading     = true;

    try {
      final all = await _apiService.fetchRemainTableDetailMTDID(
          div, date, 'All', 'All');
      _detailCacheID[cacheKey] = all;
      debugPrint('[Cache-ID] Done — ${all.length} rows (key=$cacheKey)');
      return _filterID(all, cusID, shipBy);
    } catch (e) {
      debugPrint('[Cache-ID] Failed: $e');
      return [];
    } finally {
      _isDetailIDLoading = false;
      if (!(_detailIDLoadCompleter?.isCompleted ?? true)) {
        _detailIDLoadCompleter!.complete();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // ── Filter ID rows ─────────────���──────────────────────────────────────────
  List<RemainTableDetailIDModel> _filterID(
      List<RemainTableDetailIDModel> all,
      String cusID,
      String shipBy,
      ) {
    if (cusID == 'All' && shipBy == 'All') return all;
    if (cusID == '' && shipBy == '') return all;
    return all.where((r) {
      final matchCus = cusID.isEmpty || cusID == 'All' || r.cusID == cusID;
      final matchShip = shipBy.isEmpty || shipBy == 'All' || r.shipBy == shipBy;
      return matchCus && matchShip;
    }).toList();
  }

  // ── Sync getters (từ cache, không gọi API) ────────────────────────────────
  List<RemainTableDetailModel> getDetail(String cusID, String shipBy) {
    const allKey = 'All|All';
    if (!_detailCache.containsKey(allKey)) return [];
    final all = _detailCache[allKey]!;
    if (cusID == 'All' && shipBy == 'All') return all;
    return all.where((r) => r.cusID == cusID && r.shipBy == shipBy).toList();
  }

  List<RemainTableDetailIDModel> getDetailID(String cusID, String shipBy) {
    if (_detailCacheID.isEmpty) return [];
    final all = _detailCacheID.values.first;
    return _filterID(all, cusID, shipBy);
  }

  // ── Clear ────���────────────────────────────────────────────────────────────
  void clearData() {
    _data                  = [];
    _detailCache           = {};
    _detailCacheID         = {};
    _lastLoadedDateString  = null;
    _lastLoadedDiv         = null;
    _detailLoadCompleter   = null;
    _detailIDLoadCompleter = null;
    notifyListeners();
  }
}