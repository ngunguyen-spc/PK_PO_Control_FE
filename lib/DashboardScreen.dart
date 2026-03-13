import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/OverviewCard.dart';
import 'package:ma_visualization/Provider/DateProvider.dart';
import 'package:ma_visualization/Provider/RemainTableProvider.dart';
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
  String _selectedDiv = 'KVH';

  @override
  Widget build(BuildContext context) {
    final dateProvider   = context.watch<DateProvider>();
    final remainProvider = context.watch<RemainTableProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Packing PO Monitoring",
        selectedDate: dateProvider.selectedDate,
        onDateChanged: (newDate) {
          context.read<DateProvider>().updateDate(newDate);
        },
        currentDate: DateTime.now(),
        lastLoadedTime:        remainProvider.lastLoadedTime,
        lastReloadTriggeredAt: remainProvider.lastReloadTriggeredAt,
        onToggleTheme: widget.onToggleTheme,
        selectedDiv: _selectedDiv,
        onDivChanged: (div) {
          setState(() => _selectedDiv = div);
        },
      ),
      body: Row(
        children: [
          OverviewCard(
            child: RemainTableScreen(
              onToggleTheme: widget.onToggleTheme,
              selectedDate: dateProvider.selectedDate,
              div: _selectedDiv,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: OverviewCard(
                  child: RemainChartScreen(
                    onToggleTheme: widget.onToggleTheme,
                    selectedDate: dateProvider.selectedDate,
                    div: _selectedDiv,
                  ),
                ),
              ),
              Expanded(
                child: OverviewCard(
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