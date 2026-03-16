// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// import '../Common/NoDataWidget.dart';
// import '../Common/TitleWithIndexBadge.dart';
// import '../Provider/DateProvider.dart';
// import '../Provider/RemainChartProvider.dart';
// import 'RemainChartWidget.dart';
//
// class RemainChartScreen extends StatefulWidget {
//   final VoidCallback onToggleTheme;
//   final DateTime selectedDate;
//   final String div;
//
//   const RemainChartScreen({
//     super.key,
//     required this.onToggleTheme,
//     required this.selectedDate,
//     required this.div,
//   });
//
//   @override
//   State<RemainChartScreen> createState() => _RemainChartScreenState();
// }
//
// class _RemainChartScreenState extends State<RemainChartScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<RemainChartProvider>(context, listen: false);
//       _fetchData(provider);
//     });
//   }
//
//   @override
//   void didUpdateWidget(covariant RemainChartScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // ✅ Fetch lại khi đổi date hoặc div
//     if (oldWidget.selectedDate != widget.selectedDate ||
//         oldWidget.div != widget.div) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final provider = Provider.of<RemainChartProvider>(context, listen: false);
//         _fetchData(provider);
//       });
//     }
//   }
//
//   void _fetchData(RemainChartProvider provider) {
//     final dateProvider = context.read<DateProvider>();
//     final date = DateFormat('yyyy-MM-dd').format(dateProvider.selectedDate);
//     provider.clearData();
//     provider.fetchRemainChart(widget.div, date);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dateProvider = context.watch<DateProvider>();
//     final selectedDate = dateProvider.selectedDate;
//     final title = 'PO Remain Daily';
//     final fmt = NumberFormat('#,###');
//
//     return Scaffold(
//       body: Consumer<RemainChartProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (provider.data.isEmpty) {
//             return NoDataWidget(
//               title: "No Data Available",
//               message: "Please try again with a different time range.",
//               icon: Icons.error_outline,
//               onRetry: () => _fetchData(provider),
//             );
//           }
//
//           // ✅ Tính tổng từ RemainChartModel
//           // final totalExPO   = provider.data.fold<double>(0.0, (s, e) => s + e.ex_PO);
//           // final totalFnPO   = provider.data.fold<double>(0.0, (s, e) => s + e.fn_PO);
//           // final totalRemPO  = provider.data.fold<double>(0.0, (s, e) => s + e.remain_PO);
//
//           return Column(
//             children: [
//               // ✅ Header cố định
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Lề trái: Title + Date
//                     Row(children: [
//                       TitleWithIndexBadge(index: 2, title: title),
//                       const SizedBox(width: 12),
//                       Text(
//                         '[${widget.div}]', // ✅
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       // Text(
//                       //   DateFormat('d-MMM-yyyy').format(selectedDate),
//                       //   style: const TextStyle(
//                       //       fontSize: 18, fontWeight: FontWeight.bold),
//                       // ),
//                     ]),
//
//                     // Lề phải: Summary — chỉ 3 cột theo chart
//                     // _SummaryRow(
//                     //   items: [
//                     //     _SummaryItem(label: 'Ex PO',     value: fmt.format(totalExPO)),
//                     //     _SummaryItem(label: 'Fn PO',     value: fmt.format(totalFnPO)),
//                     //     _SummaryItem(label: 'Remain PO', value: fmt.format(totalRemPO),
//                     //         highlight: totalRemPO > 0),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//               ),
//
//               const Divider(height: 1),
//
//               // ✅ Chart scroll
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: RemainChartWidget(
//                           data: provider.data,
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
// // ── Helper widgets ─────────────────────────────────────────────────────────────
//
// class _SummaryItem {
//   final String label;
//   final String value;
//   final bool highlight;
//
//   const _SummaryItem({
//     required this.label,
//     required this.value,
//     this.highlight = false,
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
//             ? (isDark ? const Color(0xFF3B1F1F) : Colors.red.shade50)
//             : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
//         final valueColor = item.highlight
//             ? Colors.red.shade700
//             : (isDark ? Colors.white : Colors.black87);
//
//         return Container(
//           margin: const EdgeInsets.only(left: 6),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: item.highlight
//                   ? Colors.red.shade200
//                   : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 item.label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 item.value,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                   color: valueColor,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../Common/NoDataWidget.dart';
import '../Common/TitleWithIndexBadge.dart';
import '../Provider/DateProvider.dart';
import '../Provider/RemainChartProvider.dart';
import 'RemainChartWidget.dart';

class RemainChartScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate;
  final String div;

  const RemainChartScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
    required this.div,
  });

  @override
  State<RemainChartScreen> createState() => _RemainChartScreenState();
}

class _RemainChartScreenState extends State<RemainChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RemainChartProvider>(context, listen: false);
      _fetchData(provider);
    });
  }

  @override
  void didUpdateWidget(covariant RemainChartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Fetch lại khi đổi date hoặc div
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.div != widget.div) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<RemainChartProvider>(context, listen: false);
        _fetchData(provider);
      });
    }
  }

  void _fetchData(RemainChartProvider provider) {
    final dateProvider = context.read<DateProvider>();
    final date = DateFormat('yyyy-MM-dd').format(dateProvider.selectedDate);
    provider.clearData();
    provider.fetchRemainChart(widget.div, date);
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    final selectedDate = dateProvider.selectedDate;
    final title = 'PO Remain Daily';
    final fmt = NumberFormat('#,###');

    return Scaffold(
      body: Consumer<RemainChartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.data.isEmpty) {
            return NoDataWidget(
              title: "No Data Available",
              message: "Please try again with a different time range.",
              icon: Icons.error_outline,
              onRetry: () => _fetchData(provider),
            );
          }

          // ✅ Tính tổng từ RemainChartModel
          // final totalExPO   = provider.data.fold<double>(0.0, (s, e) => s + e.ex_PO);
          // final totalFnPO   = provider.data.fold<double>(0.0, (s, e) => s + e.fn_PO);
          // final totalRemPO  = provider.data.fold<double>(0.0, (s, e) => s + e.remain_PO);

          return Column(
            children: [
              // ✅ Header cố định
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lề trái: Title + Date
                    Row(children: [
                      TitleWithIndexBadge(index: 3, title: title),
                      const SizedBox(width: 12),
                      Text(
                        '[${widget.div}]', // ✅
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Text(
                      //   DateFormat('d-MMM-yyyy').format(selectedDate),
                      //   style: const TextStyle(
                      //       fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                    ]),

                    // Lề phải: Summary — chỉ 3 cột theo chart
                    // _SummaryRow(
                    //   items: [
                    //     _SummaryItem(label: 'Ex PO',     value: fmt.format(totalExPO)),
                    //     _SummaryItem(label: 'Fn PO',     value: fmt.format(totalFnPO)),
                    //     _SummaryItem(label: 'Remain PO', value: fmt.format(totalRemPO),
                    //         highlight: totalRemPO > 0),
                    //   ],
                    // ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ✅ Chart scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: RemainChartWidget(
                          data: provider.data,
                          div: widget.div,
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

// ── Helper widgets ─────────────────────────────────────────────────────────────

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
            ? (isDark ? const Color(0xFF3B1F1F) : Colors.red.shade50)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
        final valueColor = item.highlight
            ? Colors.red.shade700
            : (isDark ? Colors.white : Colors.black87);

        return Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: item.highlight
                  ? Colors.red.shade200
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 15,
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