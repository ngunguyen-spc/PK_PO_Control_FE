// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
// import 'package:ma_visualization/Model/RemainTableModel.dart';
// import 'package:intl/intl.dart';
// import '../API/ApiService.dart';
//
// class RemainTableProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
//
//   // ── Summary table data ────────────────────────────────────────────────────
//   List<RemainTableModel> _data = [];
//   String? _lastLoadedDateString;
//   String? _lastLoadedDiv;
//   bool _isLoading = false;
//
//   List<RemainTableModel> get data       => _data;
//   bool                   get isLoading  => _isLoading;
//
//   // ── Detail cache ──────────────────────────────────────────────────────────
//   // Key: 'cusID|shipBy'  → list detail rows
//   // Key: '|'             → tất cả (dùng cho click tổng)
//   Map<String, List<RemainTableDetailModel>> _detailCache = {};
//   bool _isDetailLoading = false;
//
//   bool get isDetailLoading => _isDetailLoading;
//
//   /// Tra cache detail theo cusID + shipBy. Null nếu chưa có.
//   List<RemainTableDetailModel>? getDetail(String cusID, String shipBy) =>
//       _detailCache['$cusID|$shipBy'];
//
//   /// Toàn bộ detail (cho click ô tổng)
//   List<RemainTableDetailModel>? get allDetail => _detailCache['|'];
//
//   // ── Timer ─────────────────────────────────────────────────────────────────
//   DateTime _lastFetchedDate = DateTime.now();
//   String   _currentDiv     = '';
//   Timer?   _dailyTimer;
//   DateTime get lastFetchedDate => _lastFetchedDate;
//
//   // Thoi gian load lan cuoi (data ve)
//   DateTime? _lastLoadedTime;
//   DateTime? get lastLoadedTime => _lastLoadedTime;
//
//   // Thoi gian timer bat (de countdown chinh xac, khong phu thuoc thoi gian fetch)
//   DateTime? _lastReloadTriggeredAt;
//   DateTime? get lastReloadTriggeredAt => _lastReloadTriggeredAt;
//   DateTime? get nextLoadTime =>
//       _lastReloadTriggeredAt?.add(const Duration(minutes: 1));
//
//   RemainTableProvider() { _initTimer(); }
//
//   void _initTimer() {
//     _dailyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       if (_currentDiv.isNotEmpty) {
//         debugPrint('[Timer] Auto-reload — div=$_currentDiv date=$date');
//         _lastReloadTriggeredAt = DateTime.now();
//         // Reset cache check de force fetch, nhung KHONG clearData
//         // tranh UI nhay (spinner) truoc khi data moi ve
//         _lastLoadedDateString = null;
//         _lastLoadedDiv        = null;
//         _detailCache          = {};
//         notifyListeners(); // cap nhat nextLoadTime ngay lap tuc
//         fetchRemainTable(_currentDiv, date);
//       }
//     });
//   }
//
//   bool _isSameDate(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;
//
//   @override
//   void dispose() {
//     _dailyTimer?.cancel();
//     super.dispose();
//   }
//
//   // ── Fetch summary ─────────────────────────────────────────────────────────
//   Future<void> fetchRemainTable(String div, String date) async {
//     if (_lastLoadedDiv == div &&
//         _lastLoadedDateString == date &&
//         _data.isNotEmpty) return;
//
//     _currentDiv = div;
//     _isLoading  = true;
//     notifyListeners();
//
//     final result = await _apiService.fetchRemainTable(div, date);
//
//     _data                  = result;
//     _lastLoadedDiv         = div;
//     _lastLoadedDateString  = date;
//     _isLoading             = false;
//     _lastLoadedTime        = DateTime.now();
//     notifyListeners();
//
//     // ✅ Sau khi có summary → preload toàn bộ detail vào cache ngầm
//     _prefetchDetail(div, date);
//   }
//
//   // ── Prefetch detail (background, không block UI) ──────────────────────────
//   Future<void> _prefetchDetail(String div, String date) async {
//     if (_isDetailLoading) return;
//     _isDetailLoading = true;
//
//     debugPrint('[Cache] Prefetching ALL detail — div=$div date=$date');
//
//     try {
//       final all = await _apiService.fetchRemainTableDetail(div, date, 'All', 'All');
//
//       final Map<String, List<RemainTableDetailModel>> grouped = {};
//       for (final row in all) {
//         final key = '${row.cusID}|${row.shipBy}';
//         grouped.putIfAbsent(key, () => []).add(row);
//       }
//       // Key 'All|All' = toan bo (cho click o tong)
//       grouped['All|All'] = all;
//
//       _detailCache = grouped;
//
//       debugPrint('[Cache] Prefetch done — ${all.length} rows, ${grouped.length} keys: ${grouped.keys.toList()}');
//     } catch (e) {
//       debugPrint('[Cache] Prefetch failed: $e');
//     } finally {
//       _isDetailLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ── Public: lay detail (cache-first, filter tu All|All) ─────────────────
//   Future<List<RemainTableDetailModel>> fetchDetail({
//     required String div,
//     required String date,
//     required String cusID,
//     required String shipBy,
//   }) async {
//     // Neu All|All da co trong cache → filter truc tiep, khong goi API
//     final allKey = 'All|All';
//     if (_detailCache.containsKey(allKey)) {
//       final all = _detailCache[allKey]!;
//
//       if (cusID == 'All' && shipBy == 'All') {
//         debugPrint('[Cache] HIT All|All (${all.length} rows)');
//         return all;
//       }
//
//       final filtered = all
//           .where((r) => r.cusID == cusID && r.shipBy == shipBy)
//           .toList();
//       debugPrint('[Cache] HIT filter cusID=$cusID shipBy=$shipBy → ${filtered.length} rows');
//       return filtered;
//     }
//
//     // Cache chua san sang (prefetch dang chay) → goi API fallback
//     debugPrint('[Cache] MISS All|All → calling API  div=$div date=$date cusID=$cusID shipBy=$shipBy');
//     final result = await _apiService.fetchRemainTableDetail(div, date, cusID, shipBy);
//     debugPrint('[Cache] API returned ${result.length} rows (not stored, wait for prefetch)');
//     return result;
//   }
//
//   // ── Clear ─────────────────────────────────────────────────────────────────
//   void clearData() {
//     _data                 = [];
//     _detailCache          = {};
//     _lastLoadedDateString = null;
//     _lastLoadedDiv        = null;
//     notifyListeners();
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:intl/intl.dart';
import '../API/ApiService.dart';

class RemainTableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ── Summary table data ────────────────────────────────────────────────────
  List<RemainTableModel> _data = [];
  String? _lastLoadedDateString;
  String? _lastLoadedDiv;
  bool _isLoading = false;

  List<RemainTableModel> get data        => _data;
  bool                   get isLoading   => _isLoading && _data.isEmpty; // spinner chi khi chua co data
  bool                   get isRefreshing => _isLoading && _data.isNotEmpty; // refresh ngam

  // ── Detail cache ──────────────────────────────────────────────────────────
  // Key: 'cusID|shipBy'  → list detail rows
  // Key: '|'             → tất cả (dùng cho click tổng)
  Map<String, List<RemainTableDetailModel>> _detailCache = {};
  bool _isDetailLoading = false;

  bool get isDetailLoading => _isDetailLoading;

  /// Tra cache detail theo cusID + shipBy. Null nếu chưa có.
  List<RemainTableDetailModel>? getDetail(String cusID, String shipBy) =>
      _detailCache['$cusID|$shipBy'];

  /// Toàn bộ detail (cho click ô tổng)
  List<RemainTableDetailModel>? get allDetail => _detailCache['|'];

  // ── Timer ─────────────────────────────────────────────────────────────────
  DateTime _lastFetchedDate = DateTime.now();
  String   _currentDiv     = '';
  Timer?   _dailyTimer;
  DateTime get lastFetchedDate => _lastFetchedDate;

  // Thoi gian load lan cuoi (data ve)
  DateTime? _lastLoadedTime;
  DateTime? get lastLoadedTime => _lastLoadedTime;

  // Thoi gian timer bat (de countdown chinh xac, khong phu thuoc thoi gian fetch)
  DateTime? _lastReloadTriggeredAt;
  DateTime? get lastReloadTriggeredAt => _lastReloadTriggeredAt;
  DateTime? get nextLoadTime =>
      _lastReloadTriggeredAt?.add(const Duration(minutes: 1));

  RemainTableProvider() { _initTimer(); }

  void _initTimer() {
    _dailyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_currentDiv.isNotEmpty) {
        debugPrint('[Timer] Auto-reload — div=$_currentDiv date=$date');
        _lastReloadTriggeredAt = DateTime.now();
        // Reset cache check de force fetch, nhung KHONG clearData
        // tranh UI nhay (spinner) truoc khi data moi ve
        _lastLoadedDateString = null;
        _lastLoadedDiv        = null;
        _detailCache          = {};
        notifyListeners(); // cap nhat nextLoadTime ngay lap tuc
        fetchRemainTable(_currentDiv, date);
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

  // ── Fetch summary ─────────────────────────────────────────────────────────
  Future<void> fetchRemainTable(String div, String date) async {
    if (_lastLoadedDiv == div &&
        _lastLoadedDateString == date &&
        _data.isNotEmpty) return;

    _currentDiv            = div;
    _lastReloadTriggeredAt = DateTime.now(); // set ngay khi bat dau fetch
    _isLoading             = true;
    notifyListeners();

    final result = await _apiService.fetchRemainTable(div, date);

    _data                  = result;
    _lastLoadedDiv         = div;
    _lastLoadedDateString  = date;
    _isLoading             = false;
    _lastLoadedTime        = DateTime.now();
    notifyListeners();

    // ✅ Sau khi có summary → preload toàn bộ detail vào cache ngầm
    _prefetchDetail(div, date);
  }

  // ── Prefetch detail (background, không block UI) ──────────────────────────
  Future<void> _prefetchDetail(String div, String date) async {
    if (_isDetailLoading) return;
    _isDetailLoading = true;

    debugPrint('[Cache] Prefetching ALL detail — div=$div date=$date');

    try {
      final all = await _apiService.fetchRemainTableDetailMTD(div, date, 'All', 'All');

      final Map<String, List<RemainTableDetailModel>> grouped = {};
      for (final row in all) {
        final key = '${row.cusID}|${row.shipBy}';
        grouped.putIfAbsent(key, () => []).add(row);
      }
      // Key 'All|All' = toan bo (cho click o tong)
      grouped['All|All'] = all;

      _detailCache = grouped;

      debugPrint('[Cache] Prefetch done — ${all.length} rows, ${grouped.length} keys: ${grouped.keys.toList()}');
    } catch (e) {
      debugPrint('[Cache] Prefetch failed: $e');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // ── Public: lay detail (cache-first, filter tu All|All) ─────────────────
  Future<List<RemainTableDetailModel>> fetchDetail({
    required String div,
    required String date,
    required String cusID,
    required String shipBy,
  }) async {
    // Neu All|All da co trong cache → filter truc tiep, khong goi API
    final allKey = 'All|All';
    if (_detailCache.containsKey(allKey)) {
      final all = _detailCache[allKey]!;

      if (cusID == 'All' && shipBy == 'All') {
        debugPrint('[Cache] HIT All|All (${all.length} rows)');
        return all;
      }

      final filtered = all
          .where((r) => r.cusID == cusID && r.shipBy == shipBy)
          .toList();
      debugPrint('[Cache] HIT filter cusID=$cusID shipBy=$shipBy → ${filtered.length} rows');
      return filtered;
    }

    // Cache chua san sang (prefetch dang chay) → goi API fallback
    debugPrint('[Cache] MISS All|All → calling API  div=$div date=$date cusID=$cusID shipBy=$shipBy');
    final result = await _apiService.fetchRemainTableDetailMTD(div, date, cusID, shipBy);
    debugPrint('[Cache] API returned ${result.length} rows (not stored, wait for prefetch)');
    return result;
  }

  // ── Clear ─────────────────────────────────────────────────────────────────
  void clearData() {
    _data                 = [];
    _detailCache          = {};
    _lastLoadedDateString = null;
    _lastLoadedDiv        = null;
    notifyListeners();
  }
}