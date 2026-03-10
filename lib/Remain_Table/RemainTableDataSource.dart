import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/RemainTableModel.dart';

/// DataSource cho DataTable
class RemainTableDataSource extends DataTableSource {
  final BuildContext context;
  final List<RemainTableModel> rows;
  final void Function(RemainTableModel) onRowTap;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  RemainTableDataSource({
    required this.context,
    required this.rows,
    required this.onRowTap,
  });

  void sort<T>(Comparable<T> Function(RemainTableModel d) getField, bool ascending) {
    rows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  /// private helper: build một cell có border-top (hoặc ẩn top border nếu hideTopBorder = true)
  Widget _buildCell(String text, {bool hideTopBorder = false}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: hideTopBorder
              ? BorderSide.none
              : const BorderSide(color: Colors.grey),
        ),
      ),
      child: Text(text),
    );
  }

  /// Render table ở vị trí row index
  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final item = rows[index];

    // Lấy dữ liệu
    final cusID = item.cusID ?? '';
    final ex_PO = item.ex_PO;
    final ex_Qty = item.ex_Qty;
    final fn_PO = item.fn_PO;
    final fn_Qty = item.fn_Qty;
    final remain_PO = item.remain_PO;
    final remain_Qty = item.remain_Qty;

    // Kiểm tra nếu trùng với dòng trước (chỉ cần làm 1 lần)
    bool sameCusGrp = false;
    bool sameShipBy = false;
    if (index > 0) {
      final prev = rows[index - 1];
      sameCusGrp = (prev.cusGrp ?? '') == (item.cusGrp ?? '');
      sameShipBy = sameCusGrp && ((prev.shipBy ?? '') == (item.shipBy ?? ''));
    }

    // Hiển thị text: nếu trùng thì để rỗng (như bạn đang làm)
    final cusGrpDisplay = sameCusGrp ? '' : (item.cusGrp ?? '');
    final shipByDisplay = sameShipBy ? '' : (item.shipBy ?? '');

    return DataRow.byIndex(
      index: index,
      cells: [
        // Chỉ ẩn top-border cho ô CusGrp nếu cùng group với dòng trước
        DataCell(
          _buildCell(cusGrpDisplay, hideTopBorder: sameCusGrp),
          onTap: () => onRowTap(item),
        ),

        // Ẩn top-border cho ShipBy nếu cùng shipBy với dòng trước
        DataCell(
          _buildCell(shipByDisplay, hideTopBorder: sameShipBy),
          onTap: () => onRowTap(item),
        ),

        // Các cột còn lại: bạn có thể điều chỉnh hideTopBorder nếu muốn ẩn đường kẻ nối giữa các row chung group
        DataCell(_buildCell(cusID), onTap: () => onRowTap(item)),
        DataCell(_buildCell(ex_PO.toString()), onTap: () => onRowTap(item)),
        DataCell(_buildCell(ex_Qty.toString()), onTap: () => onRowTap(item)),
        DataCell(_buildCell(fn_PO.toString()), onTap: () => onRowTap(item)),
        DataCell(_buildCell(fn_Qty.toString()), onTap: () => onRowTap(item)),
        DataCell(_buildCell(remain_PO.toString()), onTap: () => onRowTap(item)),
        DataCell(_buildCell(remain_Qty.toString()), onTap: () => onRowTap(item)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}