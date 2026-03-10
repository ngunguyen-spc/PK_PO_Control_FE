import 'package:flutter/material.dart';


class DivisionFilterChips extends StatelessWidget {
  final List<String> divisions;
  final List<String> selectedDivs;
  final Function(List<String>) onSelectionChanged; // đổi callback nhận list mới

  const DivisionFilterChips({
    required this.divisions,
    required this.selectedDivs,
    required this.onSelectionChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
      divisions.map((div) {
        bool isSelected = selectedDivs.contains(div);

        return FilterChip(
          label: Text(div),
          selectedColor: DepartmentUtils.getDepartmentColor(div),
          backgroundColor: DepartmentUtils.getDepartmentColor(
            div,
          ).withOpacity(0.2),
          checkmarkColor: Colors.white,
          selected: isSelected,
          onSelected: (selected) {
            List<String> newSelected = List.from(selectedDivs);
            if (selected) {
              if (div == 'KVH') {
                // chọn KVH thì bỏ hết nhóm khác
                newSelected = ['KVH'];
              } else {
                // chọn nhóm khác thì bỏ KVH nếu có
                newSelected.remove('KVH');
                newSelected.add(div);
              }
            } else {
              // bỏ chọn nhóm này
              newSelected.remove(div);
            }

            // Không cho phép bỏ hết hết nhóm (bắt buộc phải chọn ít nhất 1 nhóm)
            if (newSelected.isEmpty) {
              newSelected.add(div);
            }

            onSelectionChanged(newSelected);
          },
        );
      }).toList(),
    );
  }
}


class DepartmentUtils {
  static const Map<String, Color> _departmentColors = {
    'PRESS': Color(0xFF0077FF),
    'MOLD': Color(0xFFEF6C00),
    'GUIDE': Color(0xFF2E7D32),
    'KVH': Color(0xFF00C3FF),
  };

  static const Map<String, Color> _borderColors = {
    'PRESS': Color(0xFF5B6870),
    'MOLD': Color(0xFF71695D),
    'GUIDE': Color(0xFF3A403A),
    'KVH': Color(0xFF3B3F42),
  };

  static Color getDepartmentColor(String div) {
    return _departmentColors[div.toUpperCase()] ?? const Color(0xFF424242);
  }

  static Color getDepartmentBorderColor(String div) {
    return _borderColors[div.toUpperCase()] ?? Colors.white;
  }
}
