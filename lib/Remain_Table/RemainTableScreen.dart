// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// import '../API/ApiService.dart';
// import '../Common/AppColors.dart';
// import '../Model/RemainTableDetailModel.dart';
// import '../Popup/RemainTableDetailPopup.dart';
// import '../Common/NoDataWidget.dart';
// import '../Common/TitleWithIndexBadge.dart';
// import '../Provider/DateProvider.dart';
// import '../Provider/RemainTableProvider.dart';
// import 'RemainTableWidget.dart';
//
// class RemainTableScreen extends StatefulWidget {
//   final VoidCallback onToggleTheme;
//   final DateTime selectedDate;
//   final String div;
//
//   const RemainTableScreen({
//     super.key,
//     required this.onToggleTheme,
//     required this.selectedDate,
//     required this.div,
//   });
//
//   @override
//   State<RemainTableScreen> createState() => _RemainTableScreenState();
// }
//
// class _RemainTableScreenState extends State<RemainTableScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<RemainTableProvider>(context, listen: false);
//       _fetchData(provider, forceRefresh: false);
//     });
//   }
//
//   @override
//   void didUpdateWidget(covariant RemainTableScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.selectedDate != widget.selectedDate ||
//         oldWidget.div != widget.div) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final provider = Provider.of<RemainTableProvider>(context, listen: false);
//         // Đổi div/date → clear hẳn để show spinner (data cũ không còn liên quan)
//         _fetchData(provider, forceRefresh: true);
//       });
//     }
//   }
//
//   DateTime adjustedDateForDataFetch(DateTime date) {
//     final now = DateTime.now();
//     final isSameMonth =
//         date.year == now.year && date.month == now.month && now.day == date.day;
//     if (isSameMonth && date.day == 1) {
//       return date.subtract(const Duration(days: 1));
//     }
//     return date;
//   }
//
//   void _fetchData(RemainTableProvider provider, {required bool forceRefresh}) {
//     final dateProvider = context.read<DateProvider>();
//     final adjusted = adjustedDateForDataFetch(dateProvider.selectedDate);
//     final date = DateFormat('yyyy-MM-dd').format(adjusted);
//
//     if (forceRefresh) {
//       // Đổi div/date → xóa data cũ, show spinner
//       provider.clearData();
//     }
//     // Timer auto-reload → KHÔNG clearData, giữ data cũ cho đến khi data mới về
//     provider.fetchRemainTable(widget.div, date);
//   }
//
//   void _onSummaryTap(String label, String div, String date) async {
//     final overlay = OverlayEntry(
//       builder: (_) => const Positioned.fill(
//         child: ColoredBox(
//           color: Color(0x55000000),
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       ),
//     );
//     Overlay.of(context).insert(overlay);
//
//     try {
//       final provider = context.read<RemainTableProvider>();
//       final List<RemainTableDetailModel> details = await provider.fetchDetail(
//         div: div, date: date, cusID: 'All', shipBy: 'All',
//       );
//       overlay.remove();
//       if (!mounted) return;
//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (_) => RemainTableDetailPopup(
//           nameChart: label,
//           title: div,
//           data: details,
//           div: div,
//           cusID: 'All',
//           shipBy: 'All',
//         ),
//       );
//     } catch (e) {
//       overlay.remove();
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load details: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dateProvider = context.watch<DateProvider>();
//     final selectedDate = dateProvider.selectedDate;
//     final title = 'PO Remain';
//     final fmt = NumberFormat('#,###');
//
//     return Scaffold(
//       body: Consumer<RemainTableProvider>(
//         builder: (context, provider, child) {
//           // Spinner toàn màn hình chỉ khi chưa có data lần đầu
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (provider.data.isEmpty) {
//             return NoDataWidget(
//               title: "No Data Available",
//               message: "Please try again with a different time range.",
//               icon: Icons.error_outline,
//               onRetry: () => _fetchData(provider, forceRefresh: true),
//             );
//           }
//
//           final adjusted = adjustedDateForDataFetch(selectedDate);
//           final month = "${adjusted.year}-${adjusted.month.toString().padLeft(2, '0')}";
//
//           final totalExPO  = provider.data.fold<double>(0.0, (s, e) => s + e.ex_PO);
//           final totalExQty = provider.data.fold<double>(0.0, (s, e) => s + e.ex_Qty);
//           final totalFnPO  = provider.data.fold<double>(0.0, (s, e) => s + e.fn_PO);
//           final totalFnQty = provider.data.fold<double>(0.0, (s, e) => s + e.fn_Qty);
//           final totalRemPO = provider.data.fold<double>(0.0, (s, e) => s + e.remain_PO);
//           final totalRemQty= provider.data.fold<double>(0.0, (s, e) => s + e.remain_Qty);
//
//           return Column(
//             children: [
//               // Header cố định
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(children: [
//                       TitleWithIndexBadge(index: 2, title: title),
//                       // Spinner nhỏ khi đang refresh ngầm
//                       if (provider.isRefreshing) ...[
//                         const SizedBox(width: 8),
//                         const SizedBox(
//                           width: 14, height: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ],
//                       const SizedBox(width: 6),
//                       Text(
//                         DateFormat('d-MMM').format(adjusted),
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         '[${widget.div}]',
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                       ),
//                     ]),
//                     _SummaryRow(
//                       items: [
//                         _SummaryItem(label: 'Ex PO',   value: fmt.format(totalExPO)),
//                         _SummaryItem(label: 'Ex Qty',  value: fmt.format(totalExQty)),
//                         _SummaryItem(label: 'Fn PO',   value: fmt.format(totalFnPO)),
//                         _SummaryItem(label: 'Fn Qty',  value: fmt.format(totalFnQty)),
//                         _SummaryItem(
//                           label: 'Remain PO',
//                           value: fmt.format(totalRemPO),
//                           highlight: totalRemPO > 0,
//                           onTap: totalRemPO > 0
//                               ? () => _onSummaryTap('Remain PO', widget.div,
//                               DateFormat('yyyy-MM-dd').format(adjusted))
//                               : null,
//                         ),
//                         _SummaryItem(
//                           label: 'Remain Qty',
//                           value: fmt.format(totalRemQty),
//                           highlight: totalRemQty > 0,
//                           onTap: totalRemQty > 0
//                               ? () => _onSummaryTap('Remain Qty', widget.div,
//                               DateFormat('yyyy-MM-dd').format(adjusted))
//                               : null,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Divider(height: 1),
//
//               // Bảng scroll
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: RemainTableWidget(
//                           data: provider.data,
//                           month: month,
//                           div: widget.div,
//                           date: DateFormat('yyyy-MM-dd').format(adjusted),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//
// // ── Helper widgets ────────────────────────────────────────────────────────────
//
// class _SummaryItem {
//   final String label;
//   final String value;
//   final bool highlight;
//   final VoidCallback? onTap;
//
//   const _SummaryItem({
//     required this.label,
//     required this.value,
//     this.highlight = false,
//     this.onTap,
//   });
// }
//
// class _SummaryRow extends StatelessWidget {
//   final List<_SummaryItem> items;
//   const _SummaryRow({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: items.map((item) {
//         final bgColor = item.highlight
//             ? (isDark ? AppColors.remainBgDark : AppColors.remainBgLight)
//             : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
//
//         final valueColor = item.highlight
//             ? Colors.black87
//             : (isDark ? Colors.white : Colors.black87);
//
//         return MouseRegion(
//           cursor: item.onTap != null
//               ? SystemMouseCursors.click
//               : MouseCursor.defer,
//           child: InkWell(
//             onTap: item.onTap,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               margin: const EdgeInsets.only(left: 6),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: item.highlight
//                       ? (isDark ? AppColors.remainBorderDark : AppColors.remainBorderLight)
//                       : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     item.label,
//                     style: TextStyle(fontSize: 12, color: valueColor),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     item.value,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: valueColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../API/ApiService.dart';
import '../Common/AppColors.dart';
import '../Model/RemainTableDetailModel.dart';
import '../Popup/RemainTableDetailPopup.dart';
import '../Common/NoDataWidget.dart';
import '../Common/TitleWithIndexBadge.dart';
import '../Provider/DateProvider.dart';
import '../Provider/RemainTableProvider.dart';
import 'RemainTableWidget.dart';

class RemainTableScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate;
  final String div;

  const RemainTableScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
    required this.div,
  });

  @override
  State<RemainTableScreen> createState() => _RemainTableScreenState();
}

class _RemainTableScreenState extends State<RemainTableScreen> {
  // ✅ Toggle: true = chỉ show Remain > 0, false = show all
  bool _showRemainOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RemainTableProvider>(context, listen: false);
      _fetchData(provider, forceRefresh: false);
    });
  }

  @override
  void didUpdateWidget(covariant RemainTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.div != widget.div) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<RemainTableProvider>(context, listen: false);
        _fetchData(provider, forceRefresh: true);
      });
    }
  }

  DateTime adjustedDateForDataFetch(DateTime date) {
    final now = DateTime.now();
    final isSameMonth =
        date.year == now.year && date.month == now.month && now.day == date.day;
    if (isSameMonth && date.day == 1) {
      return date.subtract(const Duration(days: 1));
    }
    return date;
  }

  void _fetchData(RemainTableProvider provider, {required bool forceRefresh}) {
    final dateProvider = context.read<DateProvider>();
    final adjusted = adjustedDateForDataFetch(dateProvider.selectedDate);
    final date = DateFormat('yyyy-MM-dd').format(adjusted);
    if (forceRefresh) provider.clearData();
    provider.fetchRemainTable(widget.div, date);
  }

  void _onSummaryTap(String label, String div, String date) async {
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
        div: div, date: date, cusID: 'All', shipBy: 'All',
      );
      overlay.remove();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => RemainTableDetailPopup(
          nameChart: label,
          title: div,
          data: details,
          div: div,
          cusID: 'All',
          shipBy: 'All',
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
          }

          if (provider.data.isEmpty) {
            return NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
              onRetry: () => _fetchData(provider, forceRefresh: true),
            );
          }

          final adjusted = adjustedDateForDataFetch(selectedDate);
          final month = "${adjusted.year}-${adjusted.month.toString().padLeft(2, '0')}";

          // ✅ Filter data theo toggle
          final displayData = _showRemainOnly
              ? provider.data.where((e) => e.remain_PO > 0).toList()
              : provider.data;

          final totalExPO   = provider.data.fold<double>(0.0, (s, e) => s + e.ex_PO);
          final totalExQty  = provider.data.fold<double>(0.0, (s, e) => s + e.ex_Qty);
          final totalFnPO   = provider.data.fold<double>(0.0, (s, e) => s + e.fn_PO);
          final totalFnQty  = provider.data.fold<double>(0.0, (s, e) => s + e.fn_Qty);
          final totalRemPO  = provider.data.fold<double>(0.0, (s, e) => s + e.remain_PO);
          final totalRemQty = provider.data.fold<double>(0.0, (s, e) => s + e.remain_Qty);

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            children: [
              // Header cố định
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      TitleWithIndexBadge(index: 2, title: title),
                      if (provider.isRefreshing) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d-MMM').format(adjusted),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '[${widget.div}]',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),

                      // ✅ Toggle button
                      _FilterToggle(
                        showRemainOnly: _showRemainOnly,
                        isDark: isDark,
                        onToggle: (val) => setState(() => _showRemainOnly = val),
                      ),
                    ]),

                    _SummaryRow(
                      items: [
                        _SummaryItem(label: 'Ex PO',  value: fmt.format(totalExPO)),
                        _SummaryItem(label: 'Ex Qty', value: fmt.format(totalExQty)),
                        _SummaryItem(label: 'Fn PO',  value: fmt.format(totalFnPO)),
                        _SummaryItem(label: 'Fn Qty', value: fmt.format(totalFnQty)),
                        _SummaryItem(
                          label: 'Remain PO',
                          value: fmt.format(totalRemPO),
                          highlight: totalRemPO > 0,
                          onTap: totalRemPO > 0
                              ? () => _onSummaryTap('Remain PO', widget.div,
                              DateFormat('yyyy-MM-dd').format(adjusted))
                              : null,
                        ),
                        _SummaryItem(
                          label: 'Remain Qty',
                          value: fmt.format(totalRemQty),
                          highlight: totalRemQty > 0,
                          onTap: totalRemQty > 0
                              ? () => _onSummaryTap('Remain Qty', widget.div,
                              DateFormat('yyyy-MM-dd').format(adjusted))
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RemainTableWidget(
                          data: displayData,  // ✅ dùng displayData đã filter
                          month: month,
                          div: widget.div,
                          date: DateFormat('yyyy-MM-dd').format(adjusted),
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

// ── Filter Toggle ─────────────────────────────────────────────────────────────

class _FilterToggle extends StatelessWidget {
  final bool showRemainOnly;
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _FilterToggle({
    required this.showRemainOnly,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const double w = 72;
    const double h = 28;
    const double thumbW = 34;
    const double margin = 3;
    final thumbColor = showRemainOnly ? Colors.grey : Colors.grey;

    return GestureDetector(
      onTap: () => onToggle(!showRemainOnly),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h / 2),
            child: Stack(
              children: [
                // ── Sliding thumb ──────────────────────────────────────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  top: margin,
                  left: showRemainOnly ? (w - thumbW - margin) : margin,
                  child: Container(
                    width: thumbW,
                    height: h - margin * 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((h - margin * 2) / 2),
                      color: thumbColor,
                      boxShadow: [
                        BoxShadow(
                          color: thumbColor.withOpacity(0.45),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── "All" label — bên trái ─────────────────────────────
                Positioned(
                  left: 0,
                  top: 0,
                  width: w / 2,
                  height: h,
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: !showRemainOnly
                            ? Colors.white
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),

                // ── "Rmn" label — bên phải ─────────────────────────────
                Positioned(
                  right: 0,
                  top: 0,
                  width: w / 2,
                  height: h,
                  child: Center(
                    child: Text(
                      'Rmn',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: showRemainOnly
                            ? Colors.white
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SummaryItem {
  final String label;
  final String value;
  final bool highlight;
  final VoidCallback? onTap;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.highlight = false,
    this.onTap,
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
            ? Colors.black87
            : (isDark ? Colors.white : Colors.black87);

        return MouseRegion(
          cursor: item.onTap != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.highlight
                      ? (isDark ? AppColors.remainBorderDark : AppColors.remainBorderLight)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(item.label,
                      style: TextStyle(fontSize: 12, color: valueColor)),
                  const SizedBox(height: 2),
                  Text(item.value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: valueColor)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}