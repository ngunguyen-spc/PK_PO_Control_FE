// lib/Pickup_Timeline/PickupTimelineScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ma_visualization/Common/AppColors.dart';
import 'package:ma_visualization/Common/NoDataWidget.dart';
import 'package:ma_visualization/Common/TitleWithIndexBadge.dart';
import 'package:ma_visualization/Provider/DateProvider.dart';
import 'package:ma_visualization/Provider/PickupTimelineProvider.dart';
import 'package:ma_visualization/PickupTimeline/PickupTimelineWidget.dart';

class PickupTimelineScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTime selectedDate;
  final String div;

  const PickupTimelineScreen({
    super.key,
    required this.onToggleTheme,
    required this.selectedDate,
    required this.div,
  });

  @override
  State<PickupTimelineScreen> createState() => _PickupTimelineScreenState();
}

class _PickupTimelineScreenState extends State<PickupTimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(Provider.of<PickupTimelineProvider>(context, listen: false));
    });
  }

  @override
  void didUpdateWidget(covariant PickupTimelineScreen old) {
    super.didUpdateWidget(old);
    if (old.selectedDate != widget.selectedDate || old.div != widget.div) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final p = Provider.of<PickupTimelineProvider>(context, listen: false);
        p.clearData();
        _fetchData(p);
      });
    }
  }

  void _fetchData(PickupTimelineProvider provider) {
    final date = DateFormat('yyyy-MM-dd')
        .format(context.read<DateProvider>().selectedDate);
    provider.fetchPickupTimeline(widget.div, date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PickupTimelineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.data.isEmpty) {
            return NoDataWidget(
              title: 'No Data Available',
              message: 'Please try again with a different time range.',
              icon: Icons.event_busy_outlined,
              onRetry: () { provider.clearData(); _fetchData(provider); },
            );
          }

          final data         = provider.data;
          final isDark       = Theme.of(context).brightness == Brightness.dark;
          final fmt          = NumberFormat('#,###');
          final now          = DateTime.now();
          final totalRemain  = data.fold<double>(0, (s, e) => s + e.remainPO);
          final doneCount    = data.where((e) => e.isDone).length;
          final urgentCount  = data.where((e) {
            if (e.isDone) return false;
            final m = e.pickupTime.difference(now).inMinutes;
            return m >= 0 && m < 120;
          }).length;
          final overdueCount = data.where((e) =>
          !e.isDone && e.pickupTime.isBefore(now)).length;

          return Column(children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    TitleWithIndexBadge(index: 3, title: 'Pickup Timeline'),
                    const SizedBox(width: 12),
                    Text('[${widget.div}]',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    if (provider.isRefreshing) ...[
                      const SizedBox(width: 10),
                      const SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ]),
                  Row(children: [
                    _Chip(label: 'Done', value: '$doneCount / ${data.length}',
                        isDark: isDark, highlightGreen: doneCount == data.length),
                    const SizedBox(width: 6),
                    _Chip(label: 'Remain PO',
                        value: fmt.format(totalRemain.toInt()),
                        isDark: isDark, highlightRed: totalRemain > 0),
                    if (urgentCount > 0) ...[
                      const SizedBox(width: 6),
                      _Chip(label: 'Urgent', value: '$urgentCount',
                          isDark: isDark, isUrgent: true),
                    ],
                    if (overdueCount > 0) ...[
                      const SizedBox(width: 6),
                      _Chip(label: 'Overdue', value: '$overdueCount',
                          isDark: isDark, isOverdue: true),
                    ],
                  ]),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Chart ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: PickupTimelineWidget(data: provider.data),
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label, value;
  final bool isDark;
  final bool highlightGreen, highlightRed, isUrgent, isOverdue;

  const _Chip({
    required this.label, required this.value, required this.isDark,
    this.highlightGreen = false, this.highlightRed = false,
    this.isUrgent = false, this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, border, textC;
    if (isOverdue) {
      bg = isDark ? const Color(0xFF3B1500) : Colors.deepOrange.shade50;
      border = isDark ? Colors.deepOrange.shade700 : Colors.deepOrange.shade200;
      textC  = isDark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade800;
    } else if (isUrgent) {
      bg = isDark ? const Color(0xFF3B2A00) : Colors.orange.shade50;
      border = isDark ? Colors.orange.shade800 : Colors.orange.shade200;
      textC  = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
    } else if (highlightGreen) {
      bg = isDark ? const Color(0xFF1B3A1B) : Colors.green.shade50;
      border = isDark ? Colors.green.shade800 : Colors.green.shade200;
      textC  = isDark ? Colors.green.shade300 : Colors.green.shade800;
    } else if (highlightRed) {
      bg     = isDark ? AppColors.remainBgDark.withOpacity(0.15) : AppColors.remainBgLight;
      border = AppColors.remainBorderDark;
      textC  = Colors.black87;
    } else {
      bg     = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
      border = isDark ? Colors.grey.shade600 : Colors.grey.shade300;
      textC  = isDark ? Colors.white : Colors.black87;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(label, style: TextStyle(fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.bold, color: textC)),
      ]),
    );
  }
}