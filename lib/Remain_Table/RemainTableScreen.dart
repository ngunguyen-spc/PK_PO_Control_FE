import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../Common/AppColors.dart';
import '../Common/NoDataWidget.dart';
import '../Common/TitleWithIndexBadge.dart';
import '../Provider/DateProvider.dart';
import '../Provider/RemainTableProvider.dart';
import 'RemainTableWidget.dart';

class RemainTableScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate;
  final String div;

  /// Truyền dữ liệu từ màn hình cha
  const RemainTableScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
    required this.div,
  });

  @override
  State<RemainTableScreen> createState() =>
      _RemainTableScreenState();
}

class _RemainTableScreenState extends State<RemainTableScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      Provider.of<RemainTableProvider>(context, listen: false);
      _fetchData(provider);
    });
  }

  /// Tự động chạy khi được rebuild với parameter mới (khi có thay đổi)
  @override
  void didUpdateWidget(covariant RemainTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateProvider = context.read<DateProvider>();
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.div != widget.div) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider =
        Provider.of<RemainTableProvider>(context, listen: false);
        _fetchData(provider);
      });
    }
  }

  /// Nếu là ngày 1 của tháng hiện tại, lùi 1 ngày (lấy tháng trước)
  DateTime adjustedDateForDataFetch(DateTime date) {
    final now = DateTime.now();
    final isSameMonth =
        date.year == now.year && date.month == now.month && now.day == date.day;
    if (isSameMonth && date.day == 1) {
      return date.subtract(const Duration(days: 1));
    }
    return date;
  }

  /// Gọi API chính
  void _fetchData(RemainTableProvider provider) {
    final dateProvider = context.read<DateProvider>();
    final adjusted = adjustedDateForDataFetch(dateProvider.selectedDate);
    final date = DateFormat('yyyy-MM-dd').format(adjusted);
    provider.clearData();
    provider.fetchRemainTable(widget.div, date);
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final selectedDate = dateProvider.selectedDate;
    final title = 'PO Remain';
    final fmt = NumberFormat('#,###');

    return Scaffold(
      body: Consumer<RemainTableProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());

            /// Spinner khi load data
          }

          if (provider.data.isEmpty) {
            return NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
              onRetry: () {
                _fetchData(provider);
              },
            );
          }

          final adjusted = adjustedDateForDataFetch(selectedDate);
          final month = "${adjusted.year}-${adjusted.month.toString().padLeft(
              2, '0')}";

          // ✅ Tính tổng 6 cột
          final totalExPO = provider.data.fold<double>(
              0.0, (s, e) => s + e.ex_PO);
          final totalExQty = provider.data.fold<double>(
              0.0, (s, e) => s + e.ex_Qty);
          final totalFnPO = provider.data.fold<double>(
              0.0, (s, e) => s + e.fn_PO);
          final totalFnQty = provider.data.fold<double>(
              0.0, (s, e) => s + e.fn_Qty);
          final totalRemPO = provider.data.fold<double>(
              0.0, (s, e) => s + e.remain_PO);
          final totalRemQty = provider.data.fold<double>(
              0.0, (s, e) => s + e.remain_Qty);

          return Column(
            children: [
              // ✅ Header cố định — nằm ngoài scroll
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      TitleWithIndexBadge(index: 1, title: title),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d-MMM-yyyy').format(adjusted),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '[${widget.div}]', // ✅
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                    _SummaryRow(
                      items: [
                        _SummaryItem(
                            label: 'Ex PO', value: fmt.format(totalExPO)),
                        _SummaryItem(
                            label: 'Ex Qty', value: fmt.format(totalExQty)),
                        _SummaryItem(
                            label: 'Fn PO', value: fmt.format(totalFnPO)),
                        _SummaryItem(
                            label: 'Fn Qty', value: fmt.format(totalFnQty)),
                        _SummaryItem(label: 'Remain PO',
                            value: fmt.format(totalRemPO),
                            highlight: totalRemPO > 0),
                        _SummaryItem(label: 'Remain Qty',
                            value: fmt.format(totalRemQty),
                            highlight: totalRemQty > 0),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ✅ Phần scroll — chỉ có bảng
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RemainTableWidget(
                          data: provider.data,
                          month: month,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}
class _SummaryRow extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        final bgColor = item.highlight
            ? (isDark ? AppColors.remainBgDark : AppColors.remainBgLight)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);

        final valueColor = item.highlight
            ? (isDark ? Colors.black87 : Colors.black87)
            : (isDark ? Colors.white : Colors.black87);

        return Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              // Border
              color: item.highlight
                  ? (isDark ? AppColors.remainBorderDark : AppColors.remainBorderLight)
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Căn giữa
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? valueColor : valueColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
