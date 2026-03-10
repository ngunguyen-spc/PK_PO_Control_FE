import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';

import '../Common/AppColors.dart';
import '../Popup/DetailsDataPopup.dart'; // nếu bạn muốn show popup chi tiết

class RemainTableWidget extends StatefulWidget {
  final List<RemainTableModel> data;
  final String month;

  const RemainTableWidget({super.key, required this.data, required this.month});

  @override
  State<RemainTableWidget> createState() => _RemainTableWidgetState();
}

class _RemainTableWidgetState extends State<RemainTableWidget> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;

  /// Cột nào được sort
  bool _sortAscending = true;

  /// Sort tăng dần hay giảm dần
  late RemainTableDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = RemainTableDataSource(
      context: context,
      rows: widget.data,
      onRowTap: _onRowTap,
    );
  }

  /// Nếu có thay đổi data, cập nhật lại dataSource
  @override
  void didUpdateWidget(covariant RemainTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _dataSource = RemainTableDataSource(
        context: context,
        rows: widget.data,
        onRowTap: _onRowTap,
      );
    }
  }

  /// Khi click vào row, show popup chi tiết
  void _onRowTap(RemainTableModel item) async {
    // showDialog(
    //   context: context,
    //   builder: (_) => DetailsDataPopup(
    //     nameChart: 'Remain Table Overview',
    //     title: item.dept ?? 'Detail',
    //     data: [], // nếu bạn muốn fetch chi tiết thì gọi API ở đây và truyền vào popup
    //   ),
    // );
  }

  void _sort<T>(
    Comparable<T> Function(RemainTableModel d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        columnSpacing: 32,
        horizontalMargin: 24,
        dataRowMinHeight: 28, // ✅ Giảm chiều cao tối thiểu
        dataRowMaxHeight: 36, // ✅ Giảm chiều cao tối đa
        rowsPerPage: widget.data.isEmpty ? 1 : widget.data.length,
        availableRowsPerPage: [widget.data.isEmpty ? 1 : widget.data.length],

        onRowsPerPageChanged: (r) {
          if (r != null) setState(() => _rowsPerPage = r);
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('CusGrp'),
            onSort: (i, asc) => _sort<String>((d) => d.cusGrp ?? '', i, asc),
          ),
          DataColumn(
            label: const Text('ShipBy'),
            onSort: (i, asc) => _sort<String>((d) => d.shipBy ?? '', i, asc),
          ),
          DataColumn(
            label: const Text('CusID'),
            onSort: (i, asc) => _sort<String>((d) => d.cusID ?? '', i, asc),
          ),
          DataColumn(
            label: const Text('Ex_PO'),
            onSort: (i, asc) => _sort<num>((d) => d.ex_PO, i, asc),
          ),
          DataColumn(
            label: const Text('Ex_Qty'),
            onSort: (i, asc) => _sort<num>((d) => d.ex_Qty, i, asc),
          ),
          DataColumn(
            label: const Text('Fn_PO'),
            onSort: (i, asc) => _sort<num>((d) => d.fn_PO, i, asc),
          ),
          DataColumn(
            label: const Text('Fn_Qty'),
            onSort: (i, asc) => _sort<num>((d) => d.fn_Qty, i, asc),
          ),
          DataColumn(
            label: const Text('Remain_PO'),
            onSort: (i, asc) => _sort<num>((d) => d.remain_PO, i, asc),
          ),
          DataColumn(
            label: const Text('Remain_Qty'),
            onSort: (i, asc) => _sort<num>((d) => d.remain_Qty, i, asc),
          ),
        ],
        source: _dataSource,
      ),
    );
  }
}

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

  void sort<T>(
    Comparable<T> Function(RemainTableModel d) getField,
    bool ascending,
  ) {
    rows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  /// Render table ở vị trí row index
  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final item = rows[index];

    final cusGrp = item.cusGrp;
    final shipBy = item.shipBy;
    final cusID = item.cusID;
    final ex_PO = item.ex_PO;
    final ex_Qty = item.ex_Qty;
    final fn_PO = item.fn_PO;
    final fn_Qty = item.fn_Qty;
    final remain_PO = item.remain_PO;
    final remain_Qty = item.remain_Qty;

    String cusGrpDisplay = item.cusGrp;
    String shipByDisplay = item.shipBy;

    final NumberFormat _numberFormat = NumberFormat('#,###');

    /// kiểm tra nếu trùng với dòng trước
    if (index > 0) {
      final prev = rows[index - 1];
      if (prev.cusGrp == item.cusGrp) {
        cusGrpDisplay = '';
      }
      if (prev.cusGrp == item.cusGrp && prev.shipBy == item.shipBy) {
        cusGrpDisplay = '';
        shipByDisplay = '';
      }
    }
    //
    // bool sameCusGrp = false;
    // bool sameShipBy = false;
    //
    // if (index > 0) {
    //   final prev = rows[index - 1];
    //
    //   sameCusGrp = prev.cusGrp == item.cusGrp;
    //   sameShipBy = prev.cusGrp == item.cusGrp &&
    //       prev.shipBy == item.shipBy;
    // }
    Color? cusColor = _getCusGrpColor(cusGrp);
    bool isDuplicateCus = cusGrpDisplay == '';

    Color? shipColor = _getShipByColor(shipBy);
    bool isDuplicateShip = shipByDisplay == '';

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            //padding: const EdgeInsets.symmetric(horizontal: 8),
            color: cusColor,
            child: Text(
              cusGrpDisplay,
              style: TextStyle(
                color:
                    isDuplicateCus
                        ? cusColor
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () => onRowTap(item),
        ),
        DataCell(Text(shipBy), onTap: () => onRowTap(item)),
        DataCell(Text(cusID), onTap: () => onRowTap(item)),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(_numberFormat.format(ex_PO)),
          ),
          onTap: () => onRowTap(item),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(_numberFormat.format(ex_Qty)),
          ),
          onTap: () => onRowTap(item),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(_numberFormat.format(fn_PO)),
          ),
          onTap: () => onRowTap(item),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(_numberFormat.format(fn_Qty)),
          ),
          onTap: () => onRowTap(item),
        ),
        // DataCell(Text(_numberFormat.format(ex_Qty), textAlign: TextAlign.right), onTap: () => onRowTap(item)),
        // DataCell(Text(fn_PO.toString(), textAlign: TextAlign.right), onTap: () => onRowTap(item)),
        // DataCell(Text(fn_Qty.toString(), textAlign: TextAlign.right), onTap: () => onRowTap(item)),
        // Remain_PO
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRemainColor(remain_PO),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                remain_PO == 0 ? '-' : _numberFormat.format(remain_PO),
                style: TextStyle(
                  color: remain_PO > 0
                      ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black87
                      : Colors.black87)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          onTap: () => onRowTap(item),
        ),

// Remain_Qty — tương tự
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRemainColor(remain_Qty),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                remain_Qty == 0 ? '-' : _numberFormat.format(remain_Qty),
                style: TextStyle(
                  color: remain_Qty > 0
                      ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black87
                      : Colors.black87)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          onTap: () => onRowTap(item),
        ),
        // DataCell(Text((item.act ?? 0.0).toStringAsFixed(0)), onTap: () => onRowTap(item)),
        // DataCell(Text((item.fcUsd ?? 0.0).toStringAsFixed(0)), onTap: () => onRowTap(item)),
      ],
    );
  }

  Color? _getShipByColor(String value) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    switch (value.toUpperCase()) {
      case 'SEA':
        return isDark ? Color(0xFF1F3326) : Colors.green.shade200;

      case 'EXP':
        return isDark ? Color(0xFF2A1F33) : Colors.purple.shade200;

      case 'AIR':
        return isDark ? Color(0xFF1F2A37) : Colors.blue.shade200;

      default:
        return null;
    }
  }

  Color? _getCusGrpColor(String value) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    switch (value.toUpperCase()) {
      case 'DL':
        return isDark ? Color(0xFF1F3326) : Colors.green.shade200;

      case 'MSM':
        return isDark ? Color(0xFF2A1F33) : Colors.purple.shade200;

      case 'SRG':
        return isDark ? Color(0xFF1F2A37) : Colors.blue.shade200;
      //SRG = Color(0xFF1F2A37)
      // DL  = Color(0xFF1F3326)
      // MSM = Color(0xFF2A1F33)
      default:
        return null;
    }
  }

  Color? _getRemainColor(double value) {
    if (value <= 0) return null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? AppColors.remainBgDark
        : AppColors.remainBgLight;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
