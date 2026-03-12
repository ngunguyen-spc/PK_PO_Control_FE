// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ma_visualization/Model/RemainChartModel.dart';
//
// import '../Common/AppColors.dart';
//
// class RemainChartWidget extends StatefulWidget {
//   final List<RemainChartModel> data;
//
//   const RemainChartWidget({super.key, required this.data});
//
//   @override
//   State<RemainChartWidget> createState() => _RemainChartWidgetState();
// }
//
// class _RemainChartWidgetState extends State<RemainChartWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _animation;
//   int? _touchedIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _animation = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeOutCubic, // ✅ Smooth animation
//     );
//     _animController.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant RemainChartWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.data != widget.data) {
//       _animController.reset();
//       _animController.forward();
//     }
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.data.isEmpty) return const SizedBox.shrink();
//
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final fmt = NumberFormat('#,###');
//
//     // Thay labels map cũ
//     final labels =
//         widget.data.map((e) {
//           try {
//             final dt = DateTime.parse(e.date);
//             return '${dt.day}/${dt.month}';
//           } catch (_) {
//             return e.date;
//           }
//         }).toList();
//     final today = DateTime.now();
//     final todayIndex = widget.data.indexWhere((e) {
//       try {
//         final dt = DateTime.parse(e.date);
//         return dt.day == today.day && dt.month == today.month && dt.year == today.year;
//       } catch (_) {
//         return false;
//       }
//     });
//
//     final maxY =
//         widget.data.fold<double>(0, (m, e) => e.ex_PO > m ? e.ex_PO : m) * 1.25;
//
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, _) {
//         final progress = _animation.value;
//
//         final barGroups = List.generate(widget.data.length, (i) {
//           final d = widget.data[i];
//           final isTouched = _touchedIndex == i;
//
//           // ✅ Scale theo animation progress
//           final fnPO = d.fn_PO * progress;
//           final remainPO = d.remain_PO * progress;
//           final exPO = d.ex_PO * progress;
//
//           return BarChartGroupData(
//             x: i,
//             groupVertically: false,
//             barRods: [
//               BarChartRodData(
//                 toY: exPO,
//                 width: isTouched ? 22 : 18, // ✅ Phình khi touch
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(4),
//                   topRight: Radius.circular(4),
//                 ),
//                 rodStackItems: [
//                   BarChartRodStackItem(
//                     0,
//                     fnPO,
//                     isDark ? Colors.grey.shade500 : Colors.grey.shade500,
//                   ),
//                   BarChartRodStackItem(
//                     fnPO, fnPO + remainPO,
//                     isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
//                   ),
//                   BarChartRodStackItem(
//                     fnPO + remainPO,
//                     exPO,
//                     isDark ? const Color(0xFF42A5F5) : Colors.blue.shade400,
//                   ),
//                 ],
//               ),
//             ],
//             // ✅ Số trên đầu cột
//             showingTooltipIndicators: [],
//           );
//         });
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ Legend đẹp hơn
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Row(
//                 children: [
//                   // _LegendItem(
//                   //   color:
//                   //       isDark ? const Color(0xFF42A5F5) : Colors.blue.shade400,
//                   //   label: 'Ex PO',
//                   //   isDark: isDark,
//                   // ),
//                   // const SizedBox(width: 16),
//                   _LegendItem(
//                     color:
//                         isDark
//                             ? Colors.grey.shade500
//                             : Colors.grey.shade500,
//                     label: 'Fn PO',
//                     isDark: isDark,
//                   ),
//                   const SizedBox(width: 16),
//                   _LegendItem(
//                     color: isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
//                     label: 'Remain PO',
//                     isDark: isDark,
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(
//               height: 300,
//               child: BarChart(
//                 BarChartData(
//                   maxY: maxY,
//                   minY: 0,
//                   groupsSpace: 6,
//                   // ✅ Giảm khoảng cách giữa cột
//                   barGroups: barGroups,
//
//                   // ✅ Background grid đẹp hơn
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: true,
//                     verticalInterval: 1,
//                     horizontalInterval: maxY / 5,
//                     getDrawingHorizontalLine:
//                         (v) => FlLine(
//                           color:
//                               isDark
//                                   ? Colors.white.withOpacity(0.07)
//                                   : Colors.grey.shade200,
//                           strokeWidth: 1,
//                           dashArray: [4, 4], // ✅ Dashed line
//                         ),
//                     getDrawingVerticalLine:
//                         (v) => FlLine(
//                           color:
//                               isDark
//                                   ? Colors.white.withOpacity(0.03)
//                                   : Colors.grey.shade100,
//                           strokeWidth: 1,
//                         ),
//                   ),
//
//                   borderData: FlBorderData(
//                     show: true,
//                     border: Border(
//                       bottom: BorderSide(
//                         color:
//                             isDark
//                                 ? Colors.grey.shade700
//                                 : Colors.grey.shade300,
//                         width: 1,
//                       ),
//                       left: BorderSide(
//                         color:
//                             isDark
//                                 ? Colors.grey.shade700
//                                 : Colors.grey.shade300,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//
//                   titlesData: FlTitlesData(
//                     // ✅ Trục Y trái
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 52,
//                         interval: maxY / 5,
//                         getTitlesWidget: (value, meta) {
//                           if (value == 0) return const SizedBox.shrink();
//                           return Text(
//                             fmt.format(value.toInt()),
//                             style: TextStyle(
//                               fontSize: 10,
//                               color:
//                                   isDark
//                                       ? Colors.grey.shade400
//                                       : Colors.grey.shade600,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//
//                     // ✅ Trục X — thêm interval: 1
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 50, // ✅ Tăng để chứa 2 dòng
//                         interval: 1,
//                         getTitlesWidget: (value, meta) {
//                           final i = value.toInt();
//                           if (i < 0 || i >= labels.length)
//                             return const SizedBox.shrink();
//                           final isTouched = _touchedIndex == i;
//
//                           // ✅ Parse thứ
//                           final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//                           String weekday = '';
//                           try {
//                             final dt = DateTime.parse(widget.data[i].date);
//                             weekday = weekdays[dt.weekday - 1];
//                           } catch (_) {}
//
//                           final isToday = i == todayIndex;
//                           //final isWeekend = weekday == 'Sat' || weekday == 'Sun';
//
//                           return SideTitleWidget(
//                             axisSide: meta.axisSide,
//                             space: 4,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   weekday,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
//                                     color: isToday
//                                         ? Colors.blueAccent.shade400
//                                         //: isWeekend
//                                        // ? Colors.orange.shade400
//                                         //: (isDark ? Colors.grey.shade500
//                                     : Colors.grey.shade500),
//                                  // ),
//                                 ),
//                                 // ✅ Badge nổi bật cho ngày hôm nay
//                                 isToday
//                                     ? Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blueAccent.shade400,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     labels[i],
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 )
//                                     : Text(
//                                   labels[i],
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
//                                     color: isTouched
//                                         ? (isDark ? Colors.white : Colors.black)
//                                         // : isWeekend
//                                         // ? Colors.orange.shade400
//                                         // : (isDark ? Colors.grey.shade400
//                                      :  Colors.grey.shade600),
//                                    ),
//                                 // ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//
//                     // ✅ Số Remain PO + % trên đầu cột (thay topTitles cũ)
//                     topTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 48, // Tăng từ 24 lên 36 để chứa 2 dòng
//                         getTitlesWidget: (value, meta) {
//                           final i = value.toInt();
//                           if (i < 0 || i >= widget.data.length)
//                             return const SizedBox.shrink();
//                           final d = widget.data[i];
//                           if (d.remain_PO == 0)
//                             return const SizedBox.shrink(); // ✅ Chỉ show khi có remain
//
//                           final pct =
//                               d.ex_PO > 0
//                                   ? (d.remain_PO / d.ex_PO * 100)
//                                       .toStringAsFixed(0)
//                                   : '0';
//
//                           return Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 fmt.format(d.remain_PO.toInt()),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
//                                 ),
//                               ),
//                               Text(
//                                 '$pct%',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: isDark ? AppColors.remainDark.withOpacity(0.8) : AppColors.remainLight.withOpacity(0.8), // ✅
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//
//                   // ✅ Tooltip đẹp hơn
//                   barTouchData: BarTouchData(
//                     touchCallback: (event, response) {
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         // ✅ Fix lỗi assertion
//                         if (!mounted) return;
//                         setState(() {
//                           if (response?.spot != null &&
//                               event is! FlPointerExitEvent &&
//                               event is! FlTapUpEvent) {
//                             _touchedIndex =
//                                 response!.spot!.touchedBarGroupIndex;
//                           } else {
//                             _touchedIndex = null;
//                           }
//                         });
//                       });
//                     },
//                     touchTooltipData: BarTouchTooltipData(
//                       tooltipRoundedRadius: 8,
//                       tooltipPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                         final d = widget.data[group.x];
//                         final remain = d.remain_PO;
//                         final pct = d.ex_PO > 0
//                             ? (remain / d.ex_PO * 100).toStringAsFixed(1)
//                             : '0';
//
//                         // ✅ Parse ngày từ date string
//                         String dateLabel = '';
//                         try {
//                           final dt = DateTime.parse(d.date);
//                           dateLabel = DateFormat('EEE, d MMM').format(dt); // "Mon, 10 Mar"
//                         } catch (_) {
//                           dateLabel = d.date;
//                         }
//
//                         return BarTooltipItem(
//                           '',
//                           const TextStyle(),
//                           children: [
//                             TextSpan(
//                               text: '📅 $dateLabel\n',  // ✅ Ngày đầy đủ
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             TextSpan(
//                               text: '🔵 Ex PO    ${fmt.format(d.ex_PO)}\n',
//                               style: TextStyle(fontSize: 14), //, color: Colors.blue.shade200
//                             ),
//                             TextSpan(
//                               text: '🟢 Fn PO    ${fmt.format(d.fn_PO)}\n',
//                               style: TextStyle(fontSize: 14), //, color: Colors.green.shade300
//                             ),
//                             TextSpan(
//                               text: '🔴 Remain  ${fmt.format(remain)}  ($pct%)', // ✅ Thêm %
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: remain > 0
//                                     ? (isDark ? AppColors.remainDark : AppColors.remainLight) // ✅
//                                     : Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _LegendItem extends StatelessWidget {
//   final Color color;
//   final String label;
//   final bool isDark;
//
//   const _LegendItem({
//     required this.color,
//     required this.label,
//     required this.isDark,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 14,
//           height: 14,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(3),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.5),
//                 blurRadius: 4,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/RemainChartModel.dart';

import '../API/ApiService.dart';
import '../Common/AppColors.dart';
import '../Model/RemainTableDetailModel.dart';
import '../Popup/RemainTableDetailPopup.dart';

class RemainChartWidget extends StatefulWidget {
  final List<RemainChartModel> data;
  final String div;

  const RemainChartWidget({super.key, required this.data, required this.div});

  @override
  State<RemainChartWidget> createState() => _RemainChartWidgetState();
}

class _RemainChartWidgetState extends State<RemainChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic, // ✅ Smooth animation
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant RemainChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Click bar → loading → API → popup ───────────────────────────────────
  void _onBarTap(int index) async {
    if (index < 0 || index >= widget.data.length) return;
    final d    = widget.data[index];
    final date = d.date; // 'yyyy-MM-dd'

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
      final List<RemainTableDetailModel> details =
      await ApiService().fetchRemainTableDetail(widget.div, date, 'All', 'All');

      overlay.remove();
      if (!mounted) return;

      // Format date cho title
      String dateLabel = date;
      try {
        final dt = DateTime.parse(date);
        dateLabel = DateFormat('d MMM yyyy').format(dt);
      } catch (_) {}

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => RemainTableDetailPopup(
          nameChart: 'Remain PO',
          title: '${widget.div} · $dateLabel',
          data: details,
          div: widget.div,
          cusID: '',
          shipBy: '',
        ),
      );
    } catch (e) {
      overlay.remove();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load details: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,###');

    // Thay labels map cũ
    final labels =
    widget.data.map((e) {
      try {
        final dt = DateTime.parse(e.date);
        return '${dt.day}/${dt.month}';
      } catch (_) {
        return e.date;
      }
    }).toList();
    final today = DateTime.now();
    final todayIndex = widget.data.indexWhere((e) {
      try {
        final dt = DateTime.parse(e.date);
        return dt.day == today.day && dt.month == today.month && dt.year == today.year;
      } catch (_) {
        return false;
      }
    });

    final maxY =
        widget.data.fold<double>(0, (m, e) => e.ex_PO > m ? e.ex_PO : m) * 1.25;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final progress = _animation.value;

        final barGroups = List.generate(widget.data.length, (i) {
          final d = widget.data[i];
          final isTouched = _touchedIndex == i;

          // ✅ Scale theo animation progress
          final fnPO = d.fn_PO * progress;
          final remainPO = d.remain_PO * progress;
          final exPO = d.ex_PO * progress;

          return BarChartGroupData(
            x: i,
            groupVertically: false,
            barRods: [
              BarChartRodData(
                toY: exPO,
                width: isTouched ? 22 : 18, // ✅ Phình khi touch
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    fnPO,
                    isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                  BarChartRodStackItem(
                    fnPO, fnPO + remainPO,
                    isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
                  ),
                  BarChartRodStackItem(
                    fnPO + remainPO,
                    exPO,
                    isDark ? const Color(0xFF42A5F5) : Colors.blue.shade400,
                  ),
                ],
              ),
            ],
            // ✅ Số trên đầu cột
            showingTooltipIndicators: [],
          );
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Legend đẹp hơn
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // _LegendItem(
                  //   color:
                  //       isDark ? const Color(0xFF42A5F5) : Colors.blue.shade400,
                  //   label: 'Ex PO',
                  //   isDark: isDark,
                  // ),
                  // const SizedBox(width: 16),
                  _LegendItem(
                    color:
                    isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                    label: 'Fn PO',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
                    label: 'Remain PO',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  groupsSpace: 6,
                  // ✅ Giảm khoảng cách giữa cột
                  barGroups: barGroups,

                  // ✅ Background grid đẹp hơn
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    verticalInterval: 1,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine:
                        (v) => FlLine(
                      color:
                      isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [4, 4], // ✅ Dashed line
                    ),
                    getDrawingVerticalLine:
                        (v) => FlLine(
                      color:
                      isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),

                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color:
                        isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                      left: BorderSide(
                        color:
                        isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),

                  titlesData: FlTitlesData(
                    // ✅ Trục Y trái
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            fmt.format(value.toInt()),
                            style: TextStyle(
                              fontSize: 10,
                              color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),

                    // ✅ Trục X — thêm interval: 1
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50, // ✅ Tăng để chứa 2 dòng
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length)
                            return const SizedBox.shrink();
                          final isTouched = _touchedIndex == i;

                          // ✅ Parse thứ
                          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          String weekday = '';
                          try {
                            final dt = DateTime.parse(widget.data[i].date);
                            weekday = weekdays[dt.weekday - 1];
                          } catch (_) {}

                          final isToday = i == todayIndex;
                          //final isWeekend = weekday == 'Sat' || weekday == 'Sun';

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  weekday,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                      color: isToday
                                          ? Colors.blueAccent.shade400
                                      //: isWeekend
                                      // ? Colors.orange.shade400
                                      //: (isDark ? Colors.grey.shade500
                                          : Colors.grey.shade500),
                                  // ),
                                ),
                                // ✅ Badge nổi bật cho ngày hôm nay
                                isToday
                                    ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.shade400,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    labels[i],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                                    : Text(
                                  labels[i],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                                      color: isTouched
                                          ? (isDark ? Colors.white : Colors.black)
                                      // : isWeekend
                                      // ? Colors.orange.shade400
                                      // : (isDark ? Colors.grey.shade400
                                          :  Colors.grey.shade600),
                                ),
                                // ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // ✅ Số Remain PO + % trên đầu cột (thay topTitles cũ)
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48, // Tăng từ 24 lên 36 để chứa 2 dòng
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= widget.data.length)
                            return const SizedBox.shrink();
                          final d = widget.data[i];
                          if (d.remain_PO == 0)
                            return const SizedBox.shrink(); // ✅ Chỉ show khi có remain

                          final pct =
                          d.ex_PO > 0
                              ? (d.remain_PO / d.ex_PO * 100)
                              .toStringAsFixed(0)
                              : '0';

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                fmt.format(d.remain_PO.toInt()),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.remainDark : AppColors.remainLight, // ✅
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.remainDark.withOpacity(0.8) : AppColors.remainLight.withOpacity(0.8), // ✅
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),

                  // ✅ Tooltip đẹp hơn
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        // ✅ Tap up → open popup
                        if (event is FlTapUpEvent && response?.spot != null) {
                          final idx = response!.spot!.touchedBarGroupIndex;
                          setState(() => _touchedIndex = null);
                          _onBarTap(idx);
                          return;
                        }
                        setState(() {
                          if (response?.spot != null &&
                              event is! FlPointerExitEvent) {
                            _touchedIndex =
                                response!.spot!.touchedBarGroupIndex;
                          } else {
                            _touchedIndex = null;
                          }
                        });
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final d = widget.data[group.x];
                        final remain = d.remain_PO;
                        final pct = d.ex_PO > 0
                            ? (remain / d.ex_PO * 100).toStringAsFixed(1)
                            : '0';

                        // ✅ Parse ngày từ date string
                        String dateLabel = '';
                        try {
                          final dt = DateTime.parse(d.date);
                          dateLabel = DateFormat('EEE, d MMM').format(dt); // "Mon, 10 Mar"
                        } catch (_) {
                          dateLabel = d.date;
                        }

                        return BarTooltipItem(
                          '',
                          const TextStyle(),
                          children: [
                            TextSpan(
                              text: '📅 $dateLabel\n',  // ✅ Ngày đầy đủ
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: '🔵 Ex PO    ${fmt.format(d.ex_PO)}\n',
                              style: TextStyle(fontSize: 14), //, color: Colors.blue.shade200
                            ),
                            TextSpan(
                              text: '🟢 Fn PO    ${fmt.format(d.fn_PO)}\n',
                              style: TextStyle(fontSize: 14), //, color: Colors.green.shade300
                            ),
                            TextSpan(
                              text: '🔴 Remain  ${fmt.format(remain)}  ($pct%)', // ✅ Thêm %
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: remain > 0
                                    ? (isDark ? AppColors.remainDark : AppColors.remainLight) // ✅
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}