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
  final String selectedDiv;                    // ✅ Đổi thành single string
  final ValueChanged<String> onDivChanged;     // ✅ Callback single string

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

          // // ✅ Single select chips
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: Row(
          //     children: _divisions.map((div) {
          //       final isSelected = widget.selectedDiv == div;
          //       return Padding(
          //         padding: const EdgeInsets.only(left: 6),
          //         child: InkWell(
          //           borderRadius: BorderRadius.circular(6),
          //           onTap: () => widget.onDivChanged(div),
          //           child: AnimatedContainer(
          //             duration: const Duration(milliseconds: 200),
          //             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          //             decoration: BoxDecoration(
          //               color: isSelected ? Colors.blue : Colors.transparent,
          //               borderRadius: BorderRadius.circular(6),
          //               border: Border.all(
          //                 color: isSelected ? Colors.blue : Colors.grey.shade600,
          //               ),
          //             ),
          //             child: Text(
          //               div,
          //               style: TextStyle(
          //                 fontSize: 13,
          //                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          //                 color: isSelected ? Colors.white : Colors.grey.shade400,
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     }).toList(),
          //   ),
          // ),

          // TimeInfoCard(
          //   finalTime: dayFormat.format(widget.currentDate),
          //   nextTime: dayFormat.format(widget.currentDate.add(const Duration(days: 1))),
          // ),
        ],
      ),
      centerTitle: true,
      actions: [
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