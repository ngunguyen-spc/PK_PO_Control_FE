import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/PickupTimelineModel.dart';
import 'package:ma_visualization/Common/AppColors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public constants — Screen dùng để tính axisHeight
// ─────────────────────────────────────────────────────────────────────────────
const double kTimeAxisHeight = 45.0; // dayRow(14)+gap(2)+hourRow(14)+tick(8)

class PickupTimelineWidget extends StatefulWidget {
  final List<PickupTimelineModel> data;
  final void Function(PickupTimelineModel item)? onRowTap;

  const PickupTimelineWidget({super.key, required this.data, this.onRowTap});

  @override
  State<PickupTimelineWidget> createState() => _PickupTimelineWidgetState();
}

class _PickupTimelineWidgetState extends State<PickupTimelineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  static const double _labelW = 145.0;
  static const double _statW = 90.0;
  static const double _rowH = 52.0;
  static const double _barH = 22.0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(covariant PickupTimelineWidget old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _animCtrl
        ..reset()
        ..forward();
      setState(() => _now = DateTime.now());
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  ({DateTime start, DateTime end}) get _range {
    if (widget.data.isEmpty) {
      final s = DateTime(_now.year, _now.month, _now.day);
      return (start: s, end: s.add(const Duration(hours: 24)));
    }
    final pickups = widget.data.map((e) => e.pickupTime);
    final earliest = pickups.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = pickups.reduce((a, b) => a.isAfter(b) ? a : b);
    final start = DateTime(earliest.year, earliest.month, earliest.day);
    final end = latest.add(const Duration(hours: 1, minutes: 30));
    return (start: start, end: end);
  }

  double _toPct(DateTime t, DateTime start, int totalMs) =>
      (t.difference(start).inMilliseconds / totalMs).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = _range;
    final totalMs = r.end.difference(r.start).inMilliseconds;
    final nowPct = _toPct(_now, r.start, totalMs);

    return AnimatedBuilder(
      animation: _anim,
      builder:
          (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._buildRows(isDark, r.start, totalMs, nowPct),
              const SizedBox(height: 8),
              _Legend(isDark: isDark),
            ],
          ),
    );
  }

  List<Widget> _buildRows(
    bool isDark,
    DateTime start,
    int totalMs,
    double nowPct,
  ) {
    final rows = <Widget>[];
    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      if (i > 0 && widget.data[i - 1].shipBy != item.shipBy) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: _labelW),
                Expanded(
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                SizedBox(width: _statW),
              ],
            ),
          ),
        );
      }
      rows.add(
        _GanttRow(
          item: item,
          now: _now,
          nowPct: nowPct,
          start: start,
          totalMs: totalMs,
          toPct: _toPct,
          progress: _anim.value,
          isDark: isDark,
          labelW: _labelW,
          statW: _statW,
          rowH: _rowH,
          barH: _barH,
          onTap: widget.onRowTap,
        ),
      );
      rows.add(const SizedBox(height: 5));
    }
    return rows;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time axis — dùng riêng từ Screen (sticky header)
// ─────────────────────────────────────────────────────────────────────────────

class PickupTimeAxis extends StatelessWidget {
  final DateTime start, end;
  final int totalMs;
  final double nowPct;
  final double labelW; // phải khớp _labelW trong Widget = 148
  final double statW; // phải khớp _statW  = 90
  final bool isDark;

  const PickupTimeAxis({
    super.key,
    required this.start,
    required this.end,
    required this.totalMs,
    required this.nowPct,
    required this.labelW,
    required this.statW,
    required this.isDark,
  });

  String _fmtHour(DateTime t) =>
      t.minute != 0 ? DateFormat('HH:mm').format(t) : '${t.hour}h';

  @override
  Widget build(BuildContext context) {
    final tickColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final hourColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final dayColor = isDark ? Colors.white : Colors.black87;
    final bgColor = Theme.of(context).cardColor; // match Card background
    final hours = end.difference(start).inHours;
    final intervalH = hours <= 12 ? 2 : (hours <= 24 ? 4 : 6);

    const double dayRowH = 14.0;
    const double gapH = 2.0;
    const double hourRowH = 14.0;
    const double tickH = 8.0;

    return Container(
      height: kTimeAxisHeight,
      color: bgColor,
      child: Row(
        children: [
          // Cột label trống — khớp với labelW của GanttRow
          SizedBox(width: labelW),
          // Cột bar — khớp với Expanded trong GanttRow
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                final w = c.maxWidth; // ← đây là bar width, khớp với GanttRow
                final dayItems = <Widget>[];
                final hourItems = <Widget>[];

                var t = start;
                while (!t.isAfter(end)) {
                  final pct = (t.difference(start).inMilliseconds / totalMs)
                      .clamp(0.0, 1.0);
                  final x = pct * w;
                  final isDay = t.hour == 0 && t.minute == 0;

                  // ── Row trên: d/M ─────────────────────────────────────
                  if (isDay) {
                    dayItems.add(
                      Positioned(
                        left: x.clamp(0.0, w - 34.0),
                        top: 0,
                        width: 34,
                        child: Text(
                          DateFormat('d/M').format(t),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dayColor,
                          ),
                        ),
                      ),
                    );
                  }

                  // ── Row dưới: Xh + tick ───────────────────────────────
                  final label = _fmtHour(t);
                  final lw = label.length <= 2 ? 18.0 : 26.0;
                  hourItems.add(
                    Positioned(
                      left: (x - lw / 2).clamp(0.0, w - lw),
                      top: dayRowH + gapH,
                      width: lw,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,

                              ///Hour
                              color:
                                  isDay ? dayColor.withOpacity(0.6) : hourColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: isDay ? tickH + 2 : tickH,
                            color:
                                isDay ? dayColor.withOpacity(0.35) : tickColor,
                          ),
                        ],
                      ),
                    ),
                  );

                  t = t.add(Duration(hours: intervalH));
                }

                // ── "Now" label — cùng row với ngày, căn giữa đường dọc ──
                // x của Now = nowPct * w  (w = bar width, giống Now line trong GanttRow)
                if (nowPct > 0 && nowPct < 1) {
                  const nowW = 34.0;
                  final nowX = nowPct * w;
                  dayItems.add(
                    Positioned(
                      left: (nowX - nowW / 2).clamp(0.0, w - nowW),
                      top: 0,
                      width: nowW,
                      child: Text(
                        'Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.blueAccent.shade400,
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    // Baseline
                    Positioned(
                      bottom: tickH,
                      left: 0,
                      right: 0,
                      child: Container(height: 1, color: tickColor),
                    ),
                    ...dayItems,
                    ...hourItems,
                  ],
                );
              },
            ),
          ),
          // Cột stat trống — khớp với statW + SizedBox(8) của GanttRow
          SizedBox(width: statW + 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Gantt row
// ─────────────────────────────────────────────────────────────────────────────

class _GanttRow extends StatelessWidget {
  final PickupTimelineModel item;
  final DateTime now;
  final double nowPct;
  final DateTime start;
  final int totalMs;
  final double Function(DateTime, DateTime, int) toPct;
  final double progress;
  final bool isDark;
  final double labelW, statW, rowH, barH;
  final void Function(PickupTimelineModel item)? onTap;

  const _GanttRow({
    required this.item,
    required this.now,
    required this.nowPct,
    required this.start,
    required this.totalMs,
    required this.toPct,
    required this.progress,
    required this.isDark,
    required this.labelW,
    required this.statW,
    required this.rowH,
    required this.barH,
    this.onTap,
  });

  Color _shipByBg(String s) {
    switch (s.toUpperCase()) {
      case 'AIR':
        return isDark ? const Color(0xFF1F2A37) : Colors.blue.shade100;
      case 'SEA':
        return isDark ? const Color(0xFF1F3326) : Colors.green.shade100;
      case 'EXP':
        return isDark ? const Color(0xFF2A1F33) : Colors.purple.shade100;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }

  Color _shipByFg(String s) {
    switch (s.toUpperCase()) {
      case 'AIR':
        return isDark ? Colors.blue.shade200 : const Color(0xFF0C447C);
      case 'SEA':
        return isDark ? Colors.green.shade200 : const Color(0xFF085041);
      case 'EXP':
        return isDark ? Colors.purple.shade200 : Colors.purple.shade800;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupPct = toPct(item.pickupTime, start, totalMs);
    final minsLeft = item.pickupTime.difference(now).inMinutes;
    final isUrgent = !item.isDone && minsLeft >= 0 && minsLeft < 120;
    final isOverdue = !item.isDone && minsLeft < 0;
    final fmt = NumberFormat('#,###');
    final timeFmt = DateFormat('HH:mm');

    final barFn = isDark ? Colors.grey.shade600 : Colors.grey.shade500;
    final barRem =
        isOverdue
            ? Colors.deepOrange.shade600
            : (isDark ? AppColors.remainBgDark : Colors.red.shade400);
    final barDone = isDark ? const Color(0xFF2E7D32) : Colors.green.shade500;

    final labelColor =
        isOverdue
            ? Colors.deepOrange.shade600
            : isUrgent
            ? (isDark ? AppColors.remainDark : AppColors.remainLight)
            : null;

    // return SizedBox(
    //   height: rowH,
    //   child: Row(children: [
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(item) : null,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: SizedBox(
          height: rowH,
          child: Row(
            children: [
              // ── Label ──────────────────────────────────────────────────────
              // SizedBox(
              //   width: labelW,
              //   child: Row(children: [
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              //       decoration: BoxDecoration(
              //           color: _shipByBg(item.shipBy),
              //           borderRadius: BorderRadius.circular(4)),
              //       child: Text(item.shipBy,
              //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              //               color: _shipByFg(item.shipBy))),
              //     ),
              //     const SizedBox(width: 6),
              //     Expanded(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(item.cusID,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              //                   color: labelColor ??
              //                       (isDark ? Colors.white : Colors.black87))),
              //           Text(
              //             isOverdue ? '⚠ Overdue ${minsLeft.abs()}m'
              //                 : isUrgent ? '⚡ ${minsLeft}m left'
              //                 : timeFmt.format(item.pickupTime),
              //             style: TextStyle(fontSize: 12,
              //                 color: labelColor ??
              //                     (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ]),
              // ),
              SizedBox(
                width: labelW,
                child: Row(
                  children: [

                    SizedBox(
                      width: 48,
                      child: Text(
                        item.cusID,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _shipByBg(item.shipBy),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.shipBy,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _shipByFg(item.shipBy),
                            ),
                          ),
                        ),

                        Text(
                          isOverdue
                              ? '⚠ Over ${minsLeft.abs()}m'
                              : isUrgent
                              ? '⚡ ${minsLeft}m left'
                              : timeFmt.format(item.pickupTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: labelColor ??
                                (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Bar ────────────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) {
                    final w = c.maxWidth;
                    final barTop = (rowH - barH) / 2;
                    final deadlineX = pickupPct * w;
                    final fnW = (item.fnPct * pickupPct * w * progress).clamp(
                      0.0,
                      deadlineX,
                    );
                    final remW = (item.remPct * pickupPct * w * progress).clamp(
                      0.0,
                      deadlineX - fnW,
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Track
                        Positioned(
                          top: barTop,
                          left: 0,
                          right: 0,
                          height: barH,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),

                        if (item.isDone) ...[
                          Positioned(
                            top: barTop,
                            left: 0,
                            width: (deadlineX * progress).clamp(0.0, w),
                            height: barH,
                            child: Container(
                              decoration: BoxDecoration(
                                color: barDone,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          if (fnW > 0)
                            Positioned(
                              top: barTop,
                              left: 0,
                              width: fnW,
                              height: barH,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: barFn,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          if (remW > 0)
                            Positioned(
                              top: barTop,
                              left: fnW,
                              width: remW,
                              height: barH,
                              child: Container(color: barRem),
                            ),
                          if (item.remainPO > 0 && remW > 32)
                            Positioned(
                              top: barTop,
                              left: fnW,
                              width: remW,
                              height: barH,
                              child: Center(
                                child: Text(
                                  fmt.format(item.remainPO.toInt()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                        ],

                        // Deadline marker
                        if (deadlineX > 2 && deadlineX < w - 2)
                          Positioned(
                            top: barTop - 6,
                            left: deadlineX - 5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Triangle(
                                  color:
                                      item.isDone
                                          ? barDone
                                          : isOverdue
                                          ? Colors.deepOrange.shade600
                                          : isUrgent
                                          ? Colors.red.shade500
                                          : Colors.blue.shade400,
                                ),
                                Container(
                                  width: 2,
                                  height: barH + 2,
                                  color:
                                      item.isDone
                                          ? barDone.withOpacity(0.7)
                                          : isOverdue
                                          ? Colors.deepOrange.shade600
                                          : isUrgent
                                          ? Colors.red.shade500
                                          : Colors.blue.shade400,
                                ),
                              ],
                            ),
                          ),

                        // Pickup time label
                        if (!item.isDone && deadlineX + 4 < w - 28)
                          Positioned(
                            top: barTop + 4,
                            left: deadlineX + 4,
                            child: Text(
                              timeFmt.format(item.pickupTime),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ),

                        // Now line — x = nowPct * w  (w = bar width)
                        if (nowPct > 0 && nowPct < 1)
                          Positioned(
                            top: barTop - 4,
                            left: nowPct * w - 1,
                            child: Container(
                              width: 2,
                              height: barH + 8,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.shade400,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // ── Stat chip ──────────────────────────────────────────────────
              SizedBox(
                width: statW,
                child:
                    item.isDone
                        ? _DoneChip(isDark: isDark)
                        : _RemainChip(
                          remain: item.remainPO,
                          pct: item.remPct,
                          isUrgent: isUrgent,
                          isOverdue: isOverdue,
                          isDark: isDark,
                        ),
              ),
              // ← SizedBox stat chip
            ],
          ), // ← Row
        ), // ← SizedBox (thêm indent)
      ), // ← MouseRegion
    );
  }
}

// ── Stat chips ────────────────────────────────────────────────────────────────

class _DoneChip extends StatelessWidget {
  final bool isDark;

  const _DoneChip({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1B3A1B) : Colors.green.shade50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isDark ? Colors.green.shade800 : Colors.green.shade200,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 13,
          color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          'Done',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
          ),
        ),
      ],
    ),
  );
}

class _RemainChip extends StatelessWidget {
  final double remain, pct;
  final bool isUrgent, isOverdue, isDark;

  const _RemainChip({
    required this.remain,
    required this.pct,
    required this.isUrgent,
    required this.isOverdue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg, border, textC;
    if (isOverdue) {
      bg = isDark ? const Color(0xFF3B1500) : Colors.deepOrange.shade50;
      border = isDark ? Colors.deepOrange.shade800 : Colors.deepOrange.shade200;
      textC = isDark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade700;
    } else {
      bg =
          isDark
              ? AppColors.remainBgDark.withOpacity(0.2)
              : AppColors.remainBgLight;
      border =
          isDark ? AppColors.remainBorderDark : AppColors.remainBorderLight;
      textC = isDark ? Colors.white : Colors.black87;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            NumberFormat('#,###').format(remain.toInt()),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textC,
            ),
          ),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color:
                  isOverdue
                      ? Colors.deepOrange.shade400
                      : (isDark ? AppColors.remainDark : AppColors.remainLight),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final bool isDark;

  const _Legend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final c = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        _legBox(
          isDark ? Colors.grey.shade600 : Colors.grey.shade500,
          'Fn PO',
          c,
        ),
        _legBox(
          isDark ? AppColors.remainBgDark : Colors.red.shade400,
          'Remain PO',
          c,
        ),
        _legBox(
          isDark ? const Color(0xFF2E7D32) : Colors.green.shade500,
          'Done',
          c,
        ),
        _legLine(Colors.blueAccent.shade400, 'Now', c),
        _legLine(Colors.blue.shade400, 'Pickup deadline', c),
      ],
    );
  }

  Widget _legBox(Color color, String label, Color textC) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: textC)),
    ],
  );

  Widget _legLine(Color color, String label, Color textC) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 2,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        color: color,
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: textC)),
    ],
  );
}

// ── Triangle ──────────────────────────────────────────────────────────────────

class _Triangle extends StatelessWidget {
  final Color color;

  const _Triangle({required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(10, 6),
    painter: _TrianglePainter(color: color),
  );
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close(),
    Paint()..color = color,
  );

  @override
  bool shouldRepaint(_TrianglePainter o) => o.color != color;
}
