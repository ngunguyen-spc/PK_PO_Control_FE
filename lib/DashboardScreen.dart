import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/OverviewCard.dart';
import 'package:ma_visualization/Provider/DateProvider.dart';
import 'package:ma_visualization/Remain_Table/RemainTableScreen.dart';
import 'package:ma_visualization/Remain_Chart/RemainChartScreen.dart';
import 'package:provider/provider.dart';

import 'Common/CustomAppBar.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DashboardScreen({super.key, required this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedDiv = 'KVH'; // ✅ Mặc định KVH

  @override
  Widget build(BuildContext context) {
    final dateProvider = context.watch<DateProvider>();
    //final repairFeeProvider = context.watch<RemainTableScreen>();

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Packing PO Monitoring",
        selectedDate: dateProvider.selectedDate,
        onDateChanged: (newDate) {
          context.read<DateProvider>().updateDate(newDate);
        },
        currentDate: DateTime.now(),
        onToggleTheme: widget.onToggleTheme,
        selectedDiv: _selectedDiv,             // ✅
        onDivChanged: (div) {
          setState(() => _selectedDiv = div);  // ✅ Rebuild → truyền xuống screens
        },
      ),
      body: Row(
        children: [
          OverviewCard(
            child: RemainTableScreen(
              onToggleTheme: widget.onToggleTheme,
              selectedDate: dateProvider.selectedDate,
              div: _selectedDiv, // ✅ Truyền xuống
            ),
          ),
          Column(
            children: [
              Expanded(
                child: OverviewCard(
                  //height: MediaQuery.of(context).size.height / 2,
                  child: RemainChartScreen(
                    onToggleTheme: widget.onToggleTheme,
                    selectedDate: dateProvider.selectedDate,
                    div: _selectedDiv, // ✅ Truyền xuống
                  ),
                ),
              ),
              Expanded(
                child: OverviewCard(
                  //height: MediaQuery.of(context).size.height / 2,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.construction, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Coming Soon',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
