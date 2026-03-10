import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ma_visualization/Model/DetailsDataModel.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';
import 'package:ma_visualization/Model/RepairFeeDailyModel.dart';
import 'package:ma_visualization/Model/RepairFeeModel.dart';


class ApiService {
  final String baseUrl = "http://localhost:9999/api";
  // final String baseUrl = "http://192.168.122.15:9092/api";

  Future<List<RepairFeeModel>> fetchRepairFee(String month) async {
    final url = Uri.parse("$baseUrl/repair_fee?month=$month");
    print("Url: $url");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Lọc dữ liệu để loại bỏ các phần tử có act == null hoặc tgt_MTD_ORG == 0
        // final filteredData =
        //     data.where((item) {
        //       return item['act'] != null && item['tgt_MTD_ORG'] != 0.0;
        //     }).toList();

        return data.map((json) => RepairFeeModel.fromJson(json)).toList();
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception caught: $e");
      return [];
    }
  }

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

  Future<List<RepairFeeDailyModel>> fetchRepairFeeDaily(String month) async {
    final url = Uri.parse("$baseUrl/repair_fee/daily?month=$month");
    print("url: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RepairFeeDailyModel.fromJson(json)).toList();
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

  Future<List<RemainChartModel>> fetchRemainChart(String div, String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/remain_chart?div=$div&date=$date'), // ✅ Sửa endpoint cho đúng
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => RemainChartModel.fromJson(e)).toList();
    }
    return [];
  }

  // Chuyển đổi JSON thành danh sách ToolCostModel
  List<RepairFeeModel> parseRepairFeeList(List<dynamic> data) {
    return data.map((json) => RepairFeeModel.fromJson(json)).toList();
  }
}
