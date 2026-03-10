// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class MonthYearDropdown extends StatelessWidget {
//   final DateTime selectedDate;
//   final Function(DateTime) onDateChanged;
//
//   const MonthYearDropdown({
//     super.key,
//     required this.selectedDate,
//     required this.onDateChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final List<DateTime> options = List.generate(
//       12,
//       (index) => DateTime(now.year, now.month - index, 1),
//     );
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade400),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<DateTime>(
//           value: selectedDate,
//           icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
//           isExpanded: true,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.blueAccent,
//           ),
//           // dropdownColor: Colors.black,
//           items:
//               options.map((date) {
//                 final label = DateFormat('MMM yyyy').format(date);
//                 return DropdownMenuItem(value: date, child: Text(label));
//               }).toList(),
//           onChanged: (value) {
//             if (value != null) {
//               onDateChanged(value);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthYearDropdown extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const MonthYearDropdown({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: now,
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('d MMM yyyy').format(selectedDate); // "9 Mar 2026"

    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
