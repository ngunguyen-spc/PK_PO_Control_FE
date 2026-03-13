import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DivisionFilterChips.dart';
import 'BlinkingText.dart';
import 'DateDisplayWidget.dart';
import 'DateDropdown.dart';
import 'TimeInfoCard.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleText;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final DateTime currentDate;
  final VoidCallback? onBack;
  final VoidCallback? onToggleTheme;
  final bool showBackButton;
  final String selectedDiv;
  final ValueChanged<String> onDivChanged;
  final DateTime? lastLoadedTime;
  final DateTime? lastReloadTriggeredAt;

  const CustomAppBar({
    super.key,
    required this.titleText,
    required this.selectedDate,
    required this.onDateChanged,
    required this.currentDate,
    this.onBack,
    this.onToggleTheme,
    this.showBackButton = false,
    required this.selectedDiv,
    required this.onDivChanged,
    this.lastLoadedTime,
    this.lastReloadTriggeredAt,
  });


  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final List<String> _divisions = ['KVH', 'PRESS', 'MOLD', 'GUIDE'];
  Color _getDivColor(String div) {
    switch (div) {
      case 'KVH':   return Colors.blue;
      case 'PRESS': return Colors.teal; // Xanh đậm
      case 'MOLD':  return Colors.purple.shade700;  // Tím nhạt
      case 'GUIDE': return Colors.green.shade600;   // Xanh lá
      default:      return Colors.blue;
    }
  }
  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('d/MMM/yyyy');

    return AppBar(
      elevation: 4,
      leading: widget.showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack)
          : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlinkingText(text: widget.titleText),
              const SizedBox(width: 16),
              DateDisplayWidget(
                selectedDate: widget.selectedDate,
                monthYearDropDown: SizedBox(
                  width: 140,
                  height: 40,
                  child: MonthYearDropdown(
                    selectedDate: widget.selectedDate,
                    onDateChanged: widget.onDateChanged,
                  ),
                ),
              ),

              const SizedBox(width: 12), // ✅ Khoảng cách giữa date và divisions
              // ✅ Chuyển divisions vào đây
              Row(
                children: _divisions.map((div) {
                  final isSelected = widget.selectedDiv == div;
                  final divColor = _getDivColor(div);

                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => widget.onDivChanged(div),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? divColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? divColor : Colors.grey.shade600,
                          ),
                        ),
                        child: Text(
                          div,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

        ],
      ),
      centerTitle: true,
      actions: [
        if (widget.lastLoadedTime != null)
          _ReloadTimeWidget(
            lastLoadedTime: widget.lastLoadedTime!,
            lastReloadTriggeredAt: widget.lastReloadTriggeredAt,
          ),
        const SizedBox(width: 8),
        if (widget.onToggleTheme != null)
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ── Reload time widget ────────────────────────────────────────────────────────
class _ReloadTimeWidget extends StatefulWidget {
  final DateTime lastLoadedTime;
  final DateTime? lastReloadTriggeredAt;

  const _ReloadTimeWidget({
    required this.lastLoadedTime,
    this.lastReloadTriggeredAt,
  });

  @override
  State<_ReloadTimeWidget> createState() => _ReloadTimeWidgetState();
}

class _ReloadTimeWidgetState extends State<_ReloadTimeWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick moi giay de cap nhat countdown
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(DateTime dt) =>
      DateFormat('HH:mm:ss').format(dt);

  String _countdown() {
    if (widget.lastReloadTriggeredAt == null) return '';
    final now = DateTime.now();
    final elapsed = now
        .difference(widget.lastReloadTriggeredAt!)
        .inSeconds;
    final remaining = 60 - elapsed;
    if (remaining <= 0) return 'updating...';
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade200;
    final subColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync, size: 14, color: Colors.greenAccent),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last: ${_fmt(widget.lastLoadedTime)}',
                style: TextStyle(fontSize: 12, color: textColor),
              ),
              if (widget.lastReloadTriggeredAt != null)
                Text(
                  'Next: ${_countdown()}',
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}