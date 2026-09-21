import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ma_visualization/Model/PickupTimelineModel.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';

import '../Model/RemainTableDetailIDModel.dart';
import '../Model/RemainTableDetailModel.dart';

class ApiService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = "http://localhost:9999/api";
  // final String baseUrl = "http://192.168.122.15:9092/api";

  // ── Persistent HTTP client (connection keep-alive, reuse) ──────────────────
  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  // ── Generic GET helper ─────────────────────────────────────────────────────
  Future<List<T>> _fetchList<T>(
    String endpoint,
    Map<String, String> params,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final url = Uri.parse("$baseUrl/$endpoint").replace(queryParameters: params);
    try {
      final response = await _client.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => fromJson(j as Map<String, dynamic>)).toList();
      } else {
        print("[$endpoint] Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("[$endpoint] Exception: $e");
      return [];
    }
  }

  Future<List<RemainTableModel>> fetchRemainTable(String div, String date) {
    return _fetchList(
      'remain_table',
      {'div': div, 'date': date},
      RemainTableModel.fromJson,
    );
  }

  Future<List<RemainTableDetailModel>> fetchRemainTableDetail(
      String div, String date, String cusID, String shipBy) {
    return _fetchList(
      'remain_table_detail',
      {'div': div, 'date': date, 'cusID': cusID, 'shipBy': shipBy},
      RemainTableDetailModel.fromJson,
    );
  }

  Future<List<RemainTableDetailModel>> fetchRemainTableDetailMTD(
      String div, String date, String cusID, String shipBy) {
    return _fetchList(
      'remain_table_detail_mtd',
      {'div': div, 'date': date, 'cusID': cusID, 'shipBy': shipBy},
      RemainTableDetailModel.fromJson,
    );
  }

  Future<List<RemainTableDetailIDModel>> fetchRemainTableDetailMTDID(
      String div, String date, String cusID, String shipBy) {
    return _fetchList(
      'remain_table_detail_mtd_id',
      {'div': div, 'date': date, 'cusID': cusID, 'shipBy': shipBy},
      RemainTableDetailIDModel.fromJson,
    );
  }

  Future<List<RemainChartModel>> fetchRemainChart(String div, String date) {
    return _fetchList(
      'remain_chart',
      {'div': div, 'date': date},
      RemainChartModel.fromJson,
    );
  }

  Future<List<PickupTimelineModel>> fetchPickupTimeline(String div, String date) {
    return _fetchList(
      'remain_pickup_time',
      {'div': div, 'date': date},
      PickupTimelineModel.fromJson,
    );
  }
}
