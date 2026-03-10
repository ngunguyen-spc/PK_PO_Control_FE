class RemainChartModel {
  final String date;
  final double ex_PO;
  final double fn_PO;
  final double remain_PO;

  RemainChartModel({
    required this.date,
    required this.ex_PO,
    required this.fn_PO,
    required this.remain_PO,
  });

  factory RemainChartModel.fromJson(Map<String, dynamic> json) {
    return RemainChartModel(
      // date: DateTime.parse(json['date'] ?? '1970-01-01'),
      date: json['ssd'] ?? '',
      ex_PO: double.tryParse(json['ex_PO'].toString()) ?? 0,
      fn_PO: double.tryParse(json['fn_PO'].toString()) ?? 0,
      remain_PO: double.tryParse(json['remain_PO'].toString()) ?? 0,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'ex_PO': ex_PO,
      'fn_PO': fn_PO,
      'remain_PO': remain_PO,
    };
  }

  RemainChartModel copyWith({
    String? date,
    double? ex_PO,
    double? fn_PO,
    double? remain_PO,
  }) {
    return RemainChartModel(
        date : date ?? this.date,
        ex_PO: ex_PO ?? this.ex_PO,
        fn_PO: fn_PO ?? this.fn_PO,
        remain_PO: remain_PO ?? this.remain_PO,
    );
  }
}
