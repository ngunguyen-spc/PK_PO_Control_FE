class RemainTableDetailIDModel {
  final String aufnr;
  final String curProcess;
  final double idQty;

  final String ssd;
  final String pickupTime;
  final String cusID;
  final String shipBy;
  final String denk;
  final String vbeln;
  final String po;
  final String div;
  final String ferth;
  final String roName;

  final double exQty;
  final double fnQty;
  final double remainQty;

  RemainTableDetailIDModel({
    required this.aufnr,
    required this.curProcess,
    required this.idQty,

    required this.ssd,
    required this.pickupTime,
    required this.cusID,
    required this.shipBy,
    required this.denk,
    required this.vbeln,
    required this.po,
    required this.div,
    required this.ferth,
    required this.roName,
    required this.exQty,
    required this.fnQty,
    required this.remainQty,
  });

  factory RemainTableDetailIDModel.fromJson(Map<String, dynamic> json) {
    return RemainTableDetailIDModel(
      aufnr: json['aufnr'] ?? '',
      curProcess: json['currentProcess'] ?? '',
      idQty: double.tryParse(json['id_Qty'].toString()) ?? 0,

      ssd: json['ssd'] ?? '',
      pickupTime: json['pickupTime'] ?? '',
      cusID: json['cusID'] ?? '',
      shipBy: json['shipBy'] ?? '',
      denk: json['denk'] ?? '',
      vbeln: json['vbeln'] ?? '',
      po: json['po'] ?? '',
      div: json['div'] ?? '',
      ferth: json['ferth'] ?? '',
      roName: json['roname'] ?? '',
      exQty: double.tryParse(json['ex_Qty'].toString()) ?? 0,
      fnQty: double.tryParse(json['fn_Qty'].toString()) ?? 0,
      remainQty: double.tryParse(json['remain_Qty'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aufnr': aufnr,
      'curProcess': curProcess,
      'idQty': idQty,

      'ssd': ssd,
      'pickupTime': pickupTime,
      'cusID': cusID,
      'shipBy': shipBy,
      'denk': denk,
      'vbeln': vbeln,
      'po': po,
      'div': div,
      'ferth': ferth,
      'roname': roName,
      'ex_Qty': exQty,
      'fn_Qty': fnQty,
      'remain_Qty': remainQty,
    };
  }

  RemainTableDetailIDModel copyWith({
    String? aufnr,
    String? curProcess,
    double? idQty,

    String? ssd,
    String? pickupTime,
    String? cusID,
    String? shipBy,
    String? denk,
    String? vbeln,
    String? po,
    String? div,
    String? ferth,
    String? roName,
    double? exQty,
    double? fnQty,
    double? remainQty,
  }) {
    return RemainTableDetailIDModel(
      aufnr: aufnr ?? this.aufnr,
      curProcess: curProcess ?? this.curProcess,
      idQty: idQty ?? this.idQty,

      ssd: ssd ?? this.ssd,
      pickupTime: pickupTime ?? this.pickupTime,
      cusID: cusID ?? this.cusID,
      shipBy: shipBy ?? this.shipBy,
      denk: denk ?? this.denk,
      vbeln: vbeln ?? this.vbeln,
      po: po ?? this.po,
      div: div ?? this.div,
      ferth: ferth ?? this.ferth,
      roName: roName ?? this.roName,
      exQty: exQty ?? this.exQty,
      fnQty: fnQty ?? this.fnQty,
      remainQty: remainQty ?? this.remainQty,
    );
  }
}