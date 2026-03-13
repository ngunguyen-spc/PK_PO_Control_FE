import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ma_visualization/Model/DetailsDataModel.dart';
import 'package:ma_visualization/Model/PickupTimelineModel.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';

import '../Model/RemainTableDetailModel.dart';


class ApiService {
  final String baseUrl = "http://localhost:9999/api";
  // final String baseUrl = "http://192.168.122.15:9092/api";

  Future<List<DetailsDataModel>> fetchDetailsDataRF(
    String month,
    String dept,
  ) async {
    final url = Uri.parse(
      "$baseUrl/details_data/repair_fee?month=$month&dept=$dept",
    );
    print("url: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DetailsDataModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception caught: $e");
      return [];
    }
  }

  Future<List<DetailsDataModel>> fetchDetailsDataRFDaily(
    String month,
    String dept,
  ) async {
    final url = Uri.parse(
      "$baseUrl/details_data/repair_fee_daily?month=$month&dept=$dept",
    );
    print("url: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DetailsDataModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception caught: $e");
      return [];
    }
  }
  Future<List<RemainTableModel>> fetchRemainTable(String div, String date) async {
    final url = Uri.parse("$baseUrl/remain_table?div=$div&date=$date");
    print("Url remain table: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((json) => RemainTableModel.fromJson(json)).toList();
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception caught: $e");
      return [];
    }
  }

  /// REMAIN TABLE DETAILS
  Future<List<RemainTableDetailModel>> fetchRemainTableDetail(String div, String date, String cusID, String shipBy) async {
    final url = Uri.parse("$baseUrl/remain_table_detail?div=$div&date=$date&cusID=$cusID&shipBy=$shipBy");
    print("Url remain table detail: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((json) => RemainTableDetailModel.fromJson(json)).toList();
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception caught: $e");
      return [];
    }
  }

  Future<List<RemainChartModel>> fetchRemainChart(String div, String date) async {
    final url = Uri.parse("$baseUrl/remain_chart?div=$div&date=$date");
    print("Url remain chart: $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => RemainChartModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<PickupTimelineModel>> fetchPickupTimeline(String div, String date) async {
    final url = Uri.parse("$baseUrl/remain_pickup_time?div=$div&date=$date");
    print("Url remain chart: $url");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => PickupTimelineModel.fromJson(e)).toList();
    }
    return [];
  }

}
