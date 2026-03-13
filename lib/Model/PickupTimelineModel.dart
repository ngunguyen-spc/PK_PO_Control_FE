// lib/Model/PickupTimelineModel.dart

class PickupTimelineModel {
  final String cusID;
  final String shipBy;
  final double exPO;
  final double fnPO;
  final double remainPO;
  final DateTime pickupTime;

  PickupTimelineModel({
    required this.cusID,
    required this.shipBy,
    required this.exPO,
    required this.fnPO,
    required this.remainPO,
    required this.pickupTime,
  });

  double get fnPct  => exPO > 0 ? fnPO    / exPO : 0.0;
  double get remPct => exPO > 0 ? remainPO / exPO : 0.0;
  bool   get isDone => remainPO <= 0;

  factory PickupTimelineModel.fromJson(Map<String, dynamic> json) {
    return PickupTimelineModel(
      cusID:     json['cusID']  ?? '',
      shipBy:    json['shipBy'] ?? '',
      exPO:      double.tryParse(json['ex_PO'].toString())     ?? 0,
      fnPO:      double.tryParse(json['fn_PO'].toString())     ?? 0,
      remainPO:  double.tryParse(json['remain_PO'].toString()) ?? 0,
      pickupTime: DateTime.tryParse(
        (json['pickup_time'] ?? json['pickupTime'] ?? '').toString().replaceAll(' ', 'T'),
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cusID':       cusID,
    'shipBy':      shipBy,
    'ex_PO':       exPO,
    'fn_PO':       fnPO,
    'remain_PO':   remainPO,
    'pickup_time': pickupTime.toIso8601String(),
  };
}