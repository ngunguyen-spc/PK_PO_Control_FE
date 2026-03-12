// lib/Model/RemainClickedCol.dart
// Enum dùng chung cho RemainTableWidget và RemainTableDetailPopup

enum RemainClickedCol { exPO, exQty, fnPO, fnQty, remainPO, remainQty }

extension RemainClickedColExt on RemainClickedCol {
  String get label {
    switch (this) {
      case RemainClickedCol.exPO:      return 'Ex PO';
      case RemainClickedCol.exQty:     return 'Ex Qty';
      case RemainClickedCol.fnPO:      return 'Fn PO';
      case RemainClickedCol.fnQty:     return 'Fn Qty';
      case RemainClickedCol.remainPO:  return 'Remain PO';
      case RemainClickedCol.remainQty: return 'Remain Qty';
    }
  }
}