class RemainTableModel {
  final String div;
  final String cusGrp;
  final String shipBy;
  final String cusID;
  final double ex_PO;
  final double ex_Qty;
  final double fn_PO;
  final double fn_Qty;
  final double remain_PO;
  final double remain_Qty;

  RemainTableModel({
    required this.div,
    required this.cusGrp,
    required this.shipBy,
    required this.cusID,
    required this.ex_PO,
    required this.ex_Qty,
    required this.fn_PO,
    required this.fn_Qty,
    required this.remain_PO,
    required this.remain_Qty,
  });

  factory RemainTableModel.fromJson(Map<String, dynamic> json) {
    return RemainTableModel(
      // date: DateTime.parse(json['date'] ?? '1970-01-01'),
      div: json['div'] ?? '',
      cusGrp: json['cusGrp'] ?? '',
      cusID: json['cusID'] ?? '',
      shipBy: json['shipBy'] ?? '',
      ex_PO: double.tryParse(json['ex_PO'].toString()) ?? 0,
      ex_Qty: double.tryParse(json['ex_Qty'].toString()) ?? 0,
      fn_PO: double.tryParse(json['fn_PO'].toString()) ?? 0,
      fn_Qty: double.tryParse(json['fn_Qty'].toString()) ?? 0,
      remain_PO: double.tryParse(json['remain_PO'].toString()) ?? 0,
      remain_Qty: double.tryParse(json['remain_Qty'].toString()) ?? 0,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'cusGrp': cusGrp,
      'shipBy': shipBy,
      'cusID': cusID,
      'ex_PO': ex_PO,
      'ex_Qty': ex_Qty,
      'fn_PO': fn_PO,
      'fn_Qty': fn_Qty,
      'remain_PO': remain_PO,
      'remain_Qty': remain_Qty,
    };
  }

  RemainTableModel copyWith({
    String? div,
    String? cusGrp,
    String? shipBy,
    String? cusID,
    double? ex_PO,
    double? ex_Qty,
    double? fn_PO,
    double? fn_Qty,
    double? remain_PO,
    double? remain_Qty
  }) {
    return RemainTableModel(
      div: div ?? this.div,
      cusGrp : cusGrp ?? this.cusGrp,
        shipBy: shipBy ?? this.shipBy,
      cusID: cusID ?? this.cusID,
      ex_PO: ex_PO ?? this.ex_PO,
      ex_Qty: ex_Qty ?? this.ex_Qty,
      fn_PO: fn_PO ?? this.fn_PO,
      fn_Qty: fn_Qty ?? this.fn_Qty,
      remain_PO: remain_PO ?? this.remain_PO,
      remain_Qty: remain_Qty ?? this.remain_Qty
    );
  }
}
