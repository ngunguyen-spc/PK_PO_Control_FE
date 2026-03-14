import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart'
    show MultiSelectDialogField;
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

import '../API/ApiService.dart';
import '../Common/AppColors.dart';

class RemainTableDetailPopup extends StatefulWidget {
  final String nameChart;
  final String title;
  final List<RemainTableDetailModel> data;
  final String div;
  final String cusID;
  final String shipBy;

  const RemainTableDetailPopup({
    Key? key,
    required this.nameChart,
    required this.title,
    required this.data,
    required this.div,
    required this.cusID,
    required this.shipBy,
  }) : super(key: key);

  @override
  State<RemainTableDetailPopup> createState() => _RemainTableDetailPopupState();
}

class _RemainTableDetailPopupState extends State<RemainTableDetailPopup> {
  final ScrollController _scrollH = ScrollController();
  final ScrollController _scrollV = ScrollController();
  final TextEditingController _filterController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _hasInput = false;
  DateTime _selectedDate = DateTime.now();

  List<RemainTableDetailModel> allData = [];
  List<RemainTableDetailModel> filteredData = [];

  // ── Column config: (label, jsonKey, isNumber) ────────────────────────────
  static const _colDefs = [
    ('SSD', 'ssd', false),
    ('CusID', 'cusID', false),
    ('ShipBy', 'shipBy', false),
    ('DENK', 'denk', false),
    ('VBELN', 'vbeln', false),
    ('PO', 'po', false),
    ('Div', 'div', false),
    ('FERTH', 'ferth', false),
    ('RONAME', 'roname', false),
    ('Ex Qty', 'ex_Qty', true),
    ('Fn Qty', 'fn_Qty', true),
    ('Remain Qty', 'remain_Qty', true),
  ];

  // ── Resizable column widths ───────────────────────────────────────────────
  late List<double> _colWidths;
  static const _defaultWidths = [
    130.0, // SSD
    100.0, // CusID
    90.0, // ShipBy
    80.0, // DENK
    120.0, // VBELN
    200.0, // PO
    70.0, // Div
    140.0, // FERTH
    220.0, // RONAME
    90.0, // Ex Qty
    90.0, // Fn Qty
    120.0, // Remain Qty
  ];
  static const _minColWidth = 50.0;

  // ── Filter state ──────────────────────────────────────────────────────────
  List<String>? selSsd;
  List<String>? selCusID;
  List<String>? selShipBy;
  List<String>? selDenk;
  List<String>? selVbeln;
  List<String>? selPo;
  List<String>? selDiv;
  List<String>? selFerth;
  List<String>? selRoname;
  List<String>? selExQty;
  List<String>? selFnQty;
  List<String>? selRemainQty;

  final Map<String, List<RemainTableDetailModel>> _cache = {};

  // ── Selection state ───────────────────────────────────────────────────────
  final Set<int> _selectedRows = {};
  int? _lastSelectedRow;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _colWidths = List.from(_defaultWidths);
    allData = widget.data;
    filteredData = widget.data;
    _filterController.addListener(() {
      setState(() {
        _hasInput = _filterController.text.trim().isNotEmpty;
        _selectedRows.clear();
      });
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    _searchFocusNode.dispose();
    _scrollH.dispose();
    _scrollV.dispose();
    super.dispose();
  }

  // ── Copy selected rows to clipboard (tab-separated, paste vao Excel) ──────
  Future<void> _copySelectedRows() async {
    if (_selectedRows.isEmpty) return;
    final rows = _selectedRows.toList()..sort();
    final buf = StringBuffer();

    // Header row
    buf.writeln(_colDefs.map((c) => c.$1).join('\t'));

    // Data rows
    for (final i in rows) {
      final j = filteredData[i].toJson();
      buf.writeln(_colDefs.map((c) => (j[c.$2] ?? '').toString()).join('\t'));
    }

    await Clipboard.setData(ClipboardData(text: buf.toString().trimRight()));
    if (mounted) {
      setState(() => _isCopied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isCopied = false);
      });
    }
  }

  // ── Row selection ────────────────────────────────────────────────────────
  void _handleRowTap(int index, bool shiftKey) {
    setState(() {
      if (shiftKey && _lastSelectedRow != null) {
        final from = _lastSelectedRow!;
        final to = index;
        final start = from < to ? from : to;
        final end = from < to ? to : from;
        for (int i = start; i <= end; i++) _selectedRows.add(i);
      } else {
        if (_selectedRows.contains(index)) {
          _selectedRows.remove(index);
        } else {
          _selectedRows.add(index);
        }
        _lastSelectedRow = index;
      }
    });
  }

  // ── Load by date ──────────────────────────────────────────────────────────
  Future<void> _loadData(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final cacheKey = '$dateStr-${widget.title}';

    if (_cache.containsKey(cacheKey)) {
      setState(() {
        allData = filteredData = _cache[cacheKey]!;
      });
      _applyFilter();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final data = await ApiService().fetchRemainTableDetail(
      widget.div,
      dateStr,
      widget.cusID,
      widget.shipBy,
    );
    if (mounted) Navigator.of(context).pop();

    setState(() {
      allData = filteredData = data;
      _cache[cacheKey] = data;
    });
    _applyFilter();
  }

  // ── Filter helpers ────────────────────────────────────────────────────────
  bool _checkHasInput() =>
      selSsd != null ||
      selCusID != null ||
      selShipBy != null ||
      selDenk != null ||
      selVbeln != null ||
      selPo != null ||
      selDiv != null ||
      selFerth != null ||
      selRoname != null ||
      selExQty != null ||
      selFnQty != null ||
      selRemainQty != null ||
      _filterController.text.trim().isNotEmpty;

  List<String> _getSelected(String key) {
    switch (key) {
      case 'ssd':
        return selSsd ?? [];
      case 'cusID':
        return selCusID ?? [];
      case 'shipBy':
        return selShipBy ?? [];
      case 'denk':
        return selDenk ?? [];
      case 'vbeln':
        return selVbeln ?? [];
      case 'po':
        return selPo ?? [];
      case 'div':
        return selDiv ?? [];
      case 'ferth':
        return selFerth ?? [];
      case 'roname':
        return selRoname ?? [];
      case 'ex_Qty':
        return selExQty ?? [];
      case 'fn_Qty':
        return selFnQty ?? [];
      case 'remain_Qty':
        return selRemainQty ?? [];
      default:
        return [];
    }
  }

  void _setSelected(String key, List<String> results) {
    final v = results.isEmpty ? null : results;
    switch (key) {
      case 'ssd':
        selSsd = v;
        break;
      case 'cusID':
        selCusID = v;
        break;
      case 'shipBy':
        selShipBy = v;
        break;
      case 'denk':
        selDenk = v;
        break;
      case 'vbeln':
        selVbeln = v;
        break;
      case 'po':
        selPo = v;
        break;
      case 'div':
        selDiv = v;
        break;
      case 'ferth':
        selFerth = v;
        break;
      case 'roname':
        selRoname = v;
        break;
      case 'ex_Qty':
        selExQty = v;
        break;
      case 'fn_Qty':
        selFnQty = v;
        break;
      case 'remain_Qty':
        selRemainQty = v;
        break;
    }
  }

  void _applyFilter() {
    final query = _filterController.text.trim().toLowerCase();
    final tokens =
        query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    setState(() {
      filteredData =
          allData.where((item) {
            final j = item.toJson();
            bool textMatch = true;
            if (tokens.isNotEmpty) {
              final searchable = [
                'ssd',
                'cusID',
                'shipBy',
                'denk',
                'vbeln',
                'po',
                'div',
                'ferth',
                'roname',
              ].map((k) => (j[k] ?? '').toString().toLowerCase()).join(' ');
              textMatch = tokens.every((t) => searchable.contains(t));
            }
            bool dropMatch = true;
            for (final col in _colDefs) {
              final sel = _getSelected(col.$2);
              if (sel.isNotEmpty) {
                final val = (j[col.$2] ?? '').toString();
                if (!sel.contains(val)) {
                  dropMatch = false;
                  break;
                }
              }
            }
            return textMatch && dropMatch;
          }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();
      selSsd =
          selCusID =
              selShipBy =
                  selDenk =
                      selVbeln =
                          selPo =
                              selDiv =
                                  selFerth =
                                      selRoname =
                                          selExQty =
                                              selFnQty = selRemainQty = null;
      filteredData = allData;
      _hasInput = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 12,
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 32,
          maxHeight: MediaQuery.of(context).size.height - 32,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 8),
              Expanded(child: _buildTable(theme)),
              const SizedBox(height: 10),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final totalExQty = filteredData.fold<double>(0, (s, e) => s + e.exQty);
    final totalRemainQty = filteredData.fold<double>(
      0,
      (s, e) => s + e.remainQty,
    );
    final totalRemainPO = filteredData.where((e) => e.remainQty > 0).length;
    final fmt = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.nameChart,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '[Details Data]',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.blueAccent.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      DateFormat('d MMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      side: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() => _selectedDate = picked);
                        await _loadData(picked);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // Reset column widths
                  Tooltip(
                    message: 'Reset column widths',
                    child: IconButton(
                      icon: const Icon(Icons.view_column_outlined, size: 20),
                      onPressed:
                          () => setState(
                            () => _colWidths = List.from(_defaultWidths),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats + Buttons
            Row(
              children: [
                _statChip(
                  'Total PO',
                  '${filteredData.length}',
                  Colors.blueAccent,
                  isDark,
                ),
                const SizedBox(width: 10),
                _statChip(
                  'Total Qty',
                  fmt.format(totalExQty),
                  Colors.blueAccent,
                  isDark,
                ),
                const SizedBox(width: 10),
                _statChip(
                  'Remain PO',
                  fmt.format(totalRemainPO),
                  AppColors.remainLight,
                  isDark,
                  highlight: true,
                ),
                const SizedBox(width: 10),
                _statChip(
                  'Remain Qty',
                  fmt.format(totalRemainQty),
                  AppColors.remainLight,
                  isDark,
                  highlight: true,
                ),
                const SizedBox(width: 16),
                // Copy button
                if (_selectedRows.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color:
                            _isCopied
                                ? Colors.green.shade700
                                : Colors.blueAccent.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FilledButton.icon(
                        icon: Icon(
                          _isCopied ? Icons.check_circle_outline : Icons.copy,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isCopied
                              ? 'Copied ${_selectedRows.length} row(s)!'
                              : 'Copy (${_selectedRows.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _isCopied ? null : _copySelectedRows,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  icon: const Icon(
                    Icons.cleaning_services_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _hasInput ? Colors.red.shade700 : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _resetFilter,
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(
                    Icons.download_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Export Excel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed:
                      () => _downloadExcel(
                        _buildExcel(filteredData),
                        '${widget.title}_${widget.nameChart}_details.xlsx',
                      ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),
        Divider(color: theme.dividerColor, thickness: 1),
        const SizedBox(height: 8),

        TextField(
          controller: _filterController,
          focusNode: _searchFocusNode,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search SSD, CusID, ShipBy, PO, RONAME ...',
            hintStyle: const TextStyle(fontSize: 15),
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _filterController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _filterController.clear();
                        _applyFilter();
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  // ── Stat chip với border ─────────────────────────────────────────────────

  Widget _statChip(
    String label,
    String value,
    Color valueColor,
    bool isDark, {
    bool highlight = false,
  }) {
    final bgColor =
        highlight
            ? (isDark
                ? AppColors.remainBgDark.withValues(alpha: 0.15)
                : AppColors.remainBgLight.withValues(alpha: 0.3))
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
    final borderColor =
        highlight
            ? AppColors.remainBorderDark
            : (isDark ? Colors.grey.shade600 : Colors.grey.shade300);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────

  Widget _buildTable(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.dividerColor.withValues(alpha: 0.4);
    final headerBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
    final fmt = NumberFormat('#,###');
    final totalWidth = _colWidths.fold(0.0, (s, w) => s + w);

    return Scrollbar(
      controller: _scrollH,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollH,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            children: [
              // ── Header row với resize handle ──
              Container(
                color: headerBg,
                child: Row(
                  children: List.generate(
                    _colDefs.length,
                    (i) => _buildHeaderCell(
                      _colDefs[i].$1,
                      _colDefs[i].$2,
                      i,
                      _colDefs[i].$3,
                      borderColor,
                      isDark,
                    ),
                  ),
                ),
              ),

              // ── Data rows ──
              Expanded(
                child:
                    filteredData.isEmpty
                        ? Center(
                          child: Text(
                            'No data',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.keyC &&
                                  HardwareKeyboard.instance.isControlPressed) {
                                _copySelectedRows();
                                return KeyEventResult.handled;
                              }
                              if (event.logicalKey ==
                                  LogicalKeyboardKey.escape) {
                                setState(() => _selectedRows.clear());
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Scrollbar(
                            controller: _scrollV,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _scrollV,
                              itemCount: filteredData.length,
                              itemBuilder:
                                  (_, i) => _buildDataRow(
                                    i,
                                    borderColor,
                                    isDark,
                                    fmt,
                                  ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header cell với drag resize
  Widget _buildHeaderCell(
    String label,
    String key,
    int colIdx,
    bool isNumber,
    Color borderColor,
    bool isDark,
  ) {
    final values = <String>{};
    for (final item in allData) {
      final v = (item.toJson()[key] ?? '').toString();
      if (v.isNotEmpty) values.add(v);
    }
    final isFiltered = _getSelected(key).isNotEmpty;
    final width = _colWidths[colIdx];

    return SizedBox(
      width: width,
      height: 48,
      child: ClipRect(
        child: Stack(
          children: [
            // Dropdown filter
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: MultiSelectDialogField<String>(
                buttonText: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isFiltered ? Colors.blueAccent : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                searchable: true,
                items:
                    (values.toList()..sort())
                        .map((v) => MultiSelectItem(v, v))
                        .toList(),
                initialValue: _getSelected(key),
                buttonIcon: Icon(
                  Icons.keyboard_arrow_down_outlined,
                  size: 16,
                  color: isFiltered ? Colors.blueAccent : Colors.grey,
                ),
                cancelText: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                confirmText: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chipDisplay: MultiSelectChipDisplay.none(),
                onConfirm:
                    (results) => setState(() {
                      _setSelected(key, results);
                      _applyFilter();
                      _hasInput = _checkHasInput();
                    }),
              ),
            ),

            // ── Resize handle — góc phải ──
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _colWidths[colIdx] = (_colWidths[colIdx] + details.delta.dx)
                        .clamp(_minColWidth, 600.0);
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: Container(
                    width: 8,
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.grey.shade600.withValues(alpha: 0.6)
                                  : Colors.grey.shade400.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          clipBehavior: Clip.hardEdge,
        ),
      ),
    );
  }

  // Data row
  Widget _buildDataRow(
    int i,
    Color borderColor,
    bool isDark,
    NumberFormat fmt,
  ) {
    final d = filteredData[i];
    final isSelected = _selectedRows.contains(i);
    final isEven = i % 2 == 0;
    final rowBg =
        isSelected
            ? (isDark
                ? Colors.blueAccent.withOpacity(0.25)
                : Colors.blue.shade50)
            : isEven
            ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
            : (isDark ? const Color(0xFF272727) : Colors.grey.shade50);
    final j = d.toJson();

    Widget txtCell(String key, int idx) => Container(
      width: _colWidths[idx],
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rowBg,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      alignment: Alignment.centerLeft,
      child: SelectableText(
        (j[key] ?? '').toString(),
        style: const TextStyle(fontSize: 14),
        maxLines: 1,
      ),
    );

    Widget numCell(String key, double value, int idx) {
      final isRemain = key.startsWith('remain');
      Widget content =
          isRemain && value > 0
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.remainBgDark : AppColors.remainBgLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  fmt.format(value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              )
              : SelectableText(
                value == 0 ? '-' : fmt.format(value),
                style: TextStyle(
                  fontSize: 14,
                  color: value == 0 ? Colors.grey.shade500 : null,
                ),
              );

      return Container(
        width: _colWidths[idx],
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: rowBg,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        alignment: Alignment.centerRight,
        child: content,
      );
    }

    return GestureDetector(
      onTap: () => _handleRowTap(i, HardwareKeyboard.instance.isShiftPressed),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            txtCell('ssd', 0),
            txtCell('cusID', 1),
            txtCell('shipBy', 2),
            txtCell('denk', 3),
            txtCell('vbeln', 4),
            txtCell('po', 5),
            txtCell('div', 6),
            txtCell('ferth', 7),
            txtCell('roname', 8),
            numCell('ex_Qty', d.exQty, 9),
            numCell('fn_Qty', d.fnQty, 10),
            numCell('remain_Qty', d.remainQty, 11),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FilledButton.icon(
        icon: const Icon(Icons.close, size: 18, color: Colors.white),
        label: const Text(
          'Close',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );

  // ── Excel ─────────────────────────────────────────────────────────────────

  Uint8List _buildExcel(List<RemainTableDetailModel> data) {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'] as xl.Sheet;
    sheet.appendRow([
      'SSD',
      'CusID',
      'ShipBy',
      'DENK',
      'VBELN',
      'PO',
      'Div',
      'FERTH',
      'RONAME',
      'Ex Qty',
      'Fn Qty',
      'Remain Qty',
    ]);
    for (final item in data) {
      final j = item.toJson();
      sheet.appendRow([
        j['ssd'],
        j['cusID'],
        j['shipBy'],
        j['denk'],
        j['vbeln'],
        j['po'],
        j['div'],
        j['ferth'],
        j['roname'],
        item.exQty,
        item.fnQty,
        item.remainQty,
      ]);
    }
    return Uint8List.fromList(excel.encode()!);
  }

  void _downloadExcel(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
