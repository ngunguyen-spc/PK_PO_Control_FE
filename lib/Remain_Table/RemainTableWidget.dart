
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/RemainTableModel.dart';

import 'package:provider/provider.dart';
import '../Provider/RemainTableProvider.dart';
import '../Common/AppColors.dart';
import '../Model/RemainClickedCol.dart';
import '../Model/RemainTableDetailModel.dart';
import '../Popup/RemainTableDetailPopup.dart';

class RemainTableWidget extends StatefulWidget {
  final List<RemainTableModel> data;
  final String month;
  final String div;
  final String date;

  const RemainTableWidget({
    super.key,
    required this.data,
    required this.month,
    required this.div,
    required this.date,
  });

  @override
  State<RemainTableWidget> createState() => _RemainTableWidgetState();
}

class _RemainTableWidgetState extends State<RemainTableWidget> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<RemainTableModel> _sortedData;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
  }

  @override
  void didUpdateWidget(covariant RemainTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _sortedData = List.from(widget.data);
    }
  }

  void _sort<T>(
      Comparable<T> Function(RemainTableModel d) getField,
      int columnIndex,
      bool ascending,
      ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortedData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  // ── Click cell → loading → API → popup ──────────────────────────────────

  void _onCellTap(RemainTableModel item, RemainClickedCol col) async {
    final overlay = OverlayEntry(
      builder: (_) => const Positioned.fill(
        child: ColoredBox(
          color: Color(0x55000000),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);

    try {
      final provider = context.read<RemainTableProvider>();
      final List<RemainTableDetailModel> details = await provider.fetchDetail(
        div:    widget.div,
        date:   widget.date,
        cusID:  item.cusID,
        shipBy: item.shipBy,
      );

      overlay.remove();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => RemainTableDetailPopup(
          nameChart: col.label,
          title: '${item.cusGrp} · ${item.shipBy} · ${item.cusID}',
          data: details,
          div:    widget.div,
          cusID:  item.cusID,
          shipBy: item.shipBy,
        ),
      );
    } catch (e) {
      overlay.remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load details: $e')),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final fmt    = NumberFormat('#,###');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 32,
          horizontalMargin: 24,
          dataRowMinHeight: 20,
          dataRowMaxHeight: 26,
          headingRowHeight: 32,  // ← thêm dòng này (mặc định là 56)
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: const Text('CusGrp'),
              onSort: (i, asc) => _sort<String>((d) => d.cusGrp, i, asc),
            ),
            DataColumn(
              label: const Text('ShipBy'),
              onSort: (i, asc) => _sort<String>((d) => d.shipBy, i, asc),
            ),
            DataColumn(
              label: const Text('CusID'),
              onSort: (i, asc) => _sort<String>((d) => d.cusID, i, asc),
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
          rows: List.generate(_sortedData.length, (index) {
            final item = _sortedData[index];

            // Merge display: ẩn text trùng với dòng trước
            String cusGrpDisplay = item.cusGrp;
            String shipByDisplay = item.shipBy;
            if (index > 0) {
              final prev = _sortedData[index - 1];
              if (prev.cusGrp == item.cusGrp) {
                cusGrpDisplay = '';
              }
              if (prev.cusGrp == item.cusGrp && prev.shipBy == item.shipBy) {
                cusGrpDisplay = '';
                shipByDisplay = '';
              }
            }

            final cusColor     = _getCusGrpColor(item.cusGrp, isDark);
            final isDuplCus    = cusGrpDisplay.isEmpty;

            return DataRow(
              cells: [
                // CusGrp
                DataCell(
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                    color: cusColor,
                    child: Text(
                      cusGrpDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDuplCus
                            ? cusColor
                            : isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.exPO),
                ),
                // ShipBy
                DataCell(
                  Text(item.shipBy),
                  onTap: () => _onCellTap(item, RemainClickedCol.exPO),
                ),
                // CusID
                DataCell(
                  Text(item.cusID),
                  onTap: () => _onCellTap(item, RemainClickedCol.exPO),
                ),
                // Ex_PO
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(fmt.format(item.ex_PO)),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.exPO),
                ),
                // Ex_Qty
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(fmt.format(item.ex_Qty)),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.exQty),
                ),
                // Fn_PO
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(fmt.format(item.fn_PO)),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.fnPO),
                ),
                // Fn_Qty
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(fmt.format(item.fn_Qty)),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.fnQty),
                ),
                // Remain_PO
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getRemainColor(item.remain_PO, isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.remain_PO == 0
                            ? '-'
                            : fmt.format(item.remain_PO),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item.remain_PO > 0
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.remainPO),
                ),
                // Remain_Qty
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getRemainColor(item.remain_Qty, isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.remain_Qty == 0
                            ? '-'
                            : fmt.format(item.remain_Qty),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item.remain_Qty > 0
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _onCellTap(item, RemainClickedCol.remainQty),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Color helpers ────────────────────────────────────────────────────────

  Color? _getCusGrpColor(String value, bool isDark) {
    switch (value.toUpperCase()) {
      case 'DL':  return isDark ? const Color(0xFF1F3326) : Colors.green.shade200;
      case 'MSM': return isDark ? const Color(0xFF2A1F33) : Colors.purple.shade200;
      case 'SRG': return isDark ? const Color(0xFF1F2A37) : Colors.blue.shade200;
      default:    return null;
    }
  }

  Color? _getRemainColor(double value, bool isDark) {
    if (value <= 0) return null;
    return isDark ? AppColors.remainBgDark : AppColors.remainBgLight;
  }
}