// import 'dart:typed_data';
//
// import 'package:excel/excel.dart' as xl;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
// import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart'
//     show MultiSelectDialogField;
// import 'package:multi_select_flutter/util/multi_select_item.dart';
// import 'package:ma_visualization/Model/RemainTableDetailIDModel.dart';
// import 'package:flutter/services.dart';
// import 'package:universal_html/html.dart' as html;
//
// import '../API/ApiService.dart';
// import '../Common/AppColors.dart';
//
// class RemainTableDetailPopup extends StatefulWidget {
//   final String nameChart;
//   final String title;
//   final List<RemainTableDetailModel> data;
//   final List<RemainTableDetailIDModel> dataID;
//   final String div;
//   final String cusID;
//   final String shipBy;
//
//   const RemainTableDetailPopup({
//     Key? key,
//     required this.nameChart,
//     required this.title,
//     required this.data,
//     required this.dataID,
//     required this.div,
//     required this.cusID,
//     required this.shipBy,
//   }) : super(key: key);
//
//   @override
//   State<RemainTableDetailPopup> createState() => _RemainTableDetailPopupState();
// }
//
// class _RemainTableDetailPopupState extends State<RemainTableDetailPopup> {
//   final ScrollController _scrollH = ScrollController();
//   final ScrollController _scrollV = ScrollController();
//   final TextEditingController _filterController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//
//   bool _hasInput = false;
//   bool _showPOView = true;
//   DateTime _selectedDate = DateTime.now();
//
//   List<RemainTableDetailModel> allData = [];
//   List<RemainTableDetailModel> filteredData = [];
//
//   // ── Column config: (label, jsonKey, isNumber) ────────────────────────────
//   static const _colDefs = [
//     ('SSD', 'ssd', false),
//     ('PickupTime', 'pickupTime', false),
//     ('CusID', 'cusID', false),
//     ('ShipBy', 'shipBy', false),
//     ('DENK', 'denk', false),
//     ('VBELN', 'vbeln', false),
//     ('PO', 'po', false),
//     ('Div', 'div', false),
//     ('FERTH', 'ferth', false),
//     ('RONAME', 'roname', false),
//     ('Ex Qty', 'ex_Qty', true),
//     ('Fn Qty', 'fn_Qty', true),
//     ('Remain Qty', 'remain_Qty', true),
//   ];
//
//   // ── Resizable column widths ───────────────────────────────────────────────
//   late List<double> _colWidths;
//   static const _defaultWidths = [
//     130.0, // SSD
//     160.0, // PickupTime
//     100.0, // CusID
//     90.0, // ShipBy
//     80.0, // DENK
//     120.0, // VBELN
//     200.0, // PO
//     70.0, // Div
//     140.0, // FERTH
//     220.0, // RONAME
//     90.0, // Ex Qty
//     90.0, // Fn Qty
//     120.0, // Remain Qty
//   ];
//   static const _minColWidth = 50.0;
//
//   // ── Filter state ──────────────────────────────────────────────────────────
//   List<String>? selSsd;
//   List<String>? selPickupTime;
//   List<String>? selCusID;
//   List<String>? selShipBy;
//   List<String>? selDenk;
//   List<String>? selVbeln;
//   List<String>? selPo;
//   List<String>? selDiv;
//   List<String>? selFerth;
//   List<String>? selRoname;
//   List<String>? selExQty;
//   List<String>? selFnQty;
//   List<String>? selRemainQty;
//
//   final Map<String, List<RemainTableDetailModel>> _cache = {};
//
//   // ── Selection state ───────────────────────────────────────────────────────
//   final Set<int> _selectedRows = {};
//   int? _lastSelectedRow;
//   bool _isCopied = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _colWidths = List.from(_defaultWidths);
//     allData = widget.data;
//     _showPOView = true;
//     filteredData = widget.data;
//     _filterController.addListener(() {
//       setState(() {
//         _hasInput = _filterController.text.trim().isNotEmpty;
//         _selectedRows.clear();
//       });
//       _applyFilter();
//     });
//   }
//
//   @override
//   void dispose() {
//     _filterController.dispose();
//     _searchFocusNode.dispose();
//     _scrollH.dispose();
//     _scrollV.dispose();
//     super.dispose();
//   }
//
//   void _switchView(bool showPO) {
//     setState(() {
//       _showPOView = showPO;
//       _selectedRows.clear();
//       _hasInput = false;
//     });
//     _resetFilter();
//   }
//
//   // ── Copy selected rows to clipboard (tab-separated, paste vao Excel) ──────
//   Future<void> _copySelectedRows() async {
//     if (_selectedRows.isEmpty) return;
//     final rows = _selectedRows.toList()..sort();
//     final buf = StringBuffer();
//     buf.writeln(_colDefs.map((c) => c.$1).join('\t'));
//     for (final i in rows) {
//       final j = filteredData[i].toJson();
//       buf.writeln(_colDefs.map((c) => (j[c.$2] ?? '').toString()).join('\t'));
//     }
//     final text = buf.toString().trimRight();
//
//     try {
//       await Clipboard.setData(ClipboardData(text: text));
//     } catch (_) {
//       // Fallback cho web không có https
//       final ta = html.TextAreaElement()
//         ..value = text
//         ..style.position = 'fixed'
//         ..style.opacity = '0';
//       html.document.body!.append(ta);
//       ta.select();
//       html.document.execCommand('copy');
//       ta.remove();
//     }
//
//     if (mounted) {
//       setState(() => _isCopied = true);
//       Future.delayed(const Duration(seconds: 2),
//               () { if (mounted) setState(() => _isCopied = false); });
//     }
//   }
//
//   // ── Row selection ────────────────────────────────────────────────────────
//   void _handleRowTap(int index, bool shiftKey) {
//     setState(() {
//       if (shiftKey && _lastSelectedRow != null) {
//         final from = _lastSelectedRow!;
//         final to = index;
//         final start = from < to ? from : to;
//         final end = from < to ? to : from;
//         for (int i = start; i <= end; i++) _selectedRows.add(i);
//       } else {
//         if (_selectedRows.contains(index)) {
//           _selectedRows.remove(index);
//         } else {
//           _selectedRows.add(index);
//         }
//         _lastSelectedRow = index;
//       }
//     });
//   }
//
//   // ── Load by date ──────────────────────────────────────────────────────────
//   Future<void> _loadData(DateTime date) async {
//     final dateStr = DateFormat('yyyy-MM-dd').format(date);
//     final cacheKey = '$dateStr-${widget.title}';
//
//     if (_cache.containsKey(cacheKey)) {
//       setState(() {
//         allData = filteredData = _cache[cacheKey]!;
//       });
//       _applyFilter();
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );
//
//     final data = await ApiService().fetchRemainTableDetailMTD(
//       widget.div,
//       dateStr,
//       widget.cusID,
//       widget.shipBy,
//     );
//     if (mounted) Navigator.of(context).pop();
//
//     setState(() {
//       allData = filteredData = data;
//       _cache[cacheKey] = data;
//     });
//     _applyFilter();
//   }
//
//   // ── Filter helpers ────────────────────────────────────────────────────────
//   bool _checkHasInput() =>
//       selSsd != null ||
//       selPickupTime != null ||
//       selCusID != null ||
//       selShipBy != null ||
//       selDenk != null ||
//       selVbeln != null ||
//       selPo != null ||
//       selDiv != null ||
//       selFerth != null ||
//       selRoname != null ||
//       selExQty != null ||
//       selFnQty != null ||
//       selRemainQty != null ||
//       _filterController.text.trim().isNotEmpty;
//
//   List<String> _getSelected(String key) {
//     switch (key) {
//       case 'ssd':
//         return selSsd ?? [];
//       case 'pickupTime':
//         return selPickupTime ?? [];
//       case 'cusID':
//         return selCusID ?? [];
//       case 'shipBy':
//         return selShipBy ?? [];
//       case 'denk':
//         return selDenk ?? [];
//       case 'vbeln':
//         return selVbeln ?? [];
//       case 'po':
//         return selPo ?? [];
//       case 'div':
//         return selDiv ?? [];
//       case 'ferth':
//         return selFerth ?? [];
//       case 'roname':
//         return selRoname ?? [];
//       case 'ex_Qty':
//         return selExQty ?? [];
//       case 'fn_Qty':
//         return selFnQty ?? [];
//       case 'remain_Qty':
//         return selRemainQty ?? [];
//       default:
//         return [];
//     }
//   }
//
//   void _setSelected(String key, List<String> results) {
//     final v = results.isEmpty ? null : results;
//     switch (key) {
//       case 'ssd':
//         selSsd = v;
//         break;
//       case 'pickupTime':
//         selPickupTime = v;
//         break;
//       case 'cusID':
//         selCusID = v;
//         break;
//       case 'shipBy':
//         selShipBy = v;
//         break;
//       case 'denk':
//         selDenk = v;
//         break;
//       case 'vbeln':
//         selVbeln = v;
//         break;
//       case 'po':
//         selPo = v;
//         break;
//       case 'div':
//         selDiv = v;
//         break;
//       case 'ferth':
//         selFerth = v;
//         break;
//       case 'roname':
//         selRoname = v;
//         break;
//       case 'ex_Qty':
//         selExQty = v;
//         break;
//       case 'fn_Qty':
//         selFnQty = v;
//         break;
//       case 'remain_Qty':
//         selRemainQty = v;
//         break;
//     }
//   }
//
//   void _applyFilter() {
//     final query = _filterController.text.trim().toLowerCase();
//     final tokens =
//         query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
//
//     setState(() {
//       filteredData =
//           allData.where((item) {
//             final j = item.toJson();
//             bool textMatch = true;
//             if (tokens.isNotEmpty) {
//               final searchable = [
//                 'ssd',
//                 'pickupTime',
//                 'cusID',
//                 'shipBy',
//                 'denk',
//                 'vbeln',
//                 'po',
//                 'div',
//                 'ferth',
//                 'roname',
//               ].map((k) => (j[k] ?? '').toString().toLowerCase()).join(' ');
//               textMatch = tokens.every((t) => searchable.contains(t));
//             }
//             bool dropMatch = true;
//             for (final col in _colDefs) {
//               final sel = _getSelected(col.$2);
//               if (sel.isNotEmpty) {
//                 final val = (j[col.$2] ?? '').toString();
//                 if (!sel.contains(val)) {
//                   dropMatch = false;
//                   break;
//                 }
//               }
//             }
//             return textMatch && dropMatch;
//           }).toList();
//     });
//   }
//
//   void _resetFilter() {
//     setState(() {
//       _filterController.clear();
//       selSsd =
//         selPickupTime =
//           selCusID =
//               selShipBy =
//                   selDenk =
//                       selVbeln =
//                           selPo =
//                               selDiv =
//                                   selFerth =
//                                       selRoname =
//                                           selExQty =
//                                               selFnQty = selRemainQty = null;
//       filteredData = allData;
//       _hasInput = false;
//     });
//   }
//
//   // ── Build ─────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 12,
//       backgroundColor: theme.colorScheme.surface,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width - 32,
//           maxHeight: MediaQuery.of(context).size.height - 32,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               _buildHeader(theme),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: _showPOView
//                     ? _buildTable(theme)          // PO view như hiện tại
//                     : _buildTableID(theme),       // ID view mới
//               ),
//               const SizedBox(height: 10),
//               _buildFooter(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Header ────────────────────────────────────────────────────────────────
//
//   Widget _buildHeader(ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     final totalExQty = filteredData.fold<double>(0, (s, e) => s + e.exQty);
//     final totalRemainQty = filteredData.fold<double>(
//       0,
//       (s, e) => s + e.remainQty,
//     );
//     final totalRemainPO = filteredData.where((e) => e.remainQty > 0).length;
//     final fmt = NumberFormat('#,###');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Row(
//                 children: [
//                   Text(
//                     widget.nameChart,
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       color: Colors.blueAccent,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '[Details Data]',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       color: Colors.blueAccent.withValues(alpha: 0.75),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   OutlinedButton.icon(
//                     icon: const Icon(Icons.calendar_today, size: 16),
//                     label: Text(
//                       DateFormat('d MMM yyyy').format(_selectedDate),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       side: BorderSide(
//                         color: Colors.blueAccent.withValues(alpha: 0.5),
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final picked = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime.now().add(const Duration(days: 365)),
//                       );
//                       if (picked != null && picked != _selectedDate) {
//                         setState(() => _selectedDate = picked);
//                         await _loadData(picked);
//                       }
//                     },
//                   ),
//                   const SizedBox(width: 8),
//                   _PoIdToggle(
//                     showPO: _showPOView,
//                     onToggle: _switchView,
//                   ),
//                   const SizedBox(width: 8),
//                   // Reset column widths
//                   Tooltip(
//                     message: 'Reset column widths',
//                     child: IconButton(
//                       icon: const Icon(Icons.view_column_outlined, size: 20),
//                       onPressed:
//                           () => setState(
//                             () => _colWidths = List.from(_defaultWidths),
//                           ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Stats + Buttons
//             Row(
//               children: [
//                 _statChip(
//                   'Total PO',
//                   '${filteredData.length}',
//                   Colors.blueAccent,
//                   isDark,
//                 ),
//                 const SizedBox(width: 10),
//                 _statChip(
//                   'Total Qty',
//                   fmt.format(totalExQty),
//                   Colors.blueAccent,
//                   isDark,
//                 ),
//                 const SizedBox(width: 10),
//                 _statChip(
//                   'Remain PO',
//                   fmt.format(totalRemainPO),
//                   AppColors.remainLight,
//                   isDark,
//                   highlight: true,
//                 ),
//                 const SizedBox(width: 10),
//                 _statChip(
//                   'Remain Qty',
//                   fmt.format(totalRemainQty),
//                   AppColors.remainLight,
//                   isDark,
//                   highlight: true,
//                 ),
//                 const SizedBox(width: 16),
//                 // Copy button
//                 if (_selectedRows.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 250),
//                       decoration: BoxDecoration(
//                         color:
//                             _isCopied
//                                 ? Colors.green.shade700
//                                 : Colors.blueAccent.shade700,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: FilledButton.icon(
//                         icon: Icon(
//                           _isCopied ? Icons.check_circle_outline : Icons.copy,
//                           size: 18,
//                           color: Colors.white,
//                         ),
//                         label: Text(
//                           _isCopied
//                               ? 'Copied ${_selectedRows.length} row(s)!'
//                               : 'Copy (${_selectedRows.length})',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         style: FilledButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         onPressed: _isCopied ? null : _copySelectedRows,
//                       ),
//                     ),
//                   ),
//                 FilledButton.icon(
//                   icon: const Icon(
//                     Icons.cleaning_services_rounded,
//                     size: 18,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     'Clear',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   style: FilledButton.styleFrom(
//                     backgroundColor:
//                         _hasInput ? Colors.red.shade700 : Colors.grey.shade700,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   onPressed: _resetFilter,
//                 ),
//                 const SizedBox(width: 8),
//                 FilledButton.icon(
//                   icon: const Icon(
//                     Icons.download_rounded,
//                     size: 18,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     'Export Excel',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   style: FilledButton.styleFrom(
//                     backgroundColor: Colors.green.shade800,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   onPressed:
//                       () => _downloadExcel(
//                         _buildExcel(filteredData),
//                         '${widget.title}_${widget.nameChart}_details.xlsx',
//                       ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//
//         const SizedBox(height: 10),
//         Divider(color: theme.dividerColor, thickness: 1),
//         const SizedBox(height: 8),
//
//         TextField(
//           controller: _filterController,
//           focusNode: _searchFocusNode,
//           style: const TextStyle(fontSize: 15),
//           decoration: InputDecoration(
//             hintText: 'Search SSD, CusID, ShipBy, PO, RONAME ...',
//             hintStyle: const TextStyle(fontSize: 15),
//             prefixIcon: const Icon(Icons.search),
//             suffixIcon:
//                 _filterController.text.isNotEmpty
//                     ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _filterController.clear();
//                         _applyFilter();
//                       },
//                     )
//                     : null,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(vertical: 12),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Stat chip với border ─────────────────────────────────────────────────
//
//   Widget _statChip(
//     String label,
//     String value,
//     Color valueColor,
//     bool isDark, {
//     bool highlight = false,
//   }) {
//     final bgColor =
//         highlight
//             ? (isDark
//                 ? AppColors.remainBgDark.withValues(alpha: 0.15)
//                 : AppColors.remainBgLight.withValues(alpha: 0.3))
//             : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
//     final borderColor =
//         highlight
//             ? AppColors.remainBorderDark
//             : (isDark ? Colors.grey.shade600 : Colors.grey.shade300);
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: borderColor, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Table ─────────────────────────────────────────────────────────────────
//
//   Widget _buildTable(ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     final borderColor = theme.dividerColor.withValues(alpha: 0.4);
//     final headerBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
//     final fmt = NumberFormat('#,###');
//     final totalWidth = _colWidths.fold(0.0, (s, w) => s + w);
//
//     return Scrollbar(
//       controller: _scrollH,
//       thumbVisibility: true,
//       child: SingleChildScrollView(
//         controller: _scrollH,
//         scrollDirection: Axis.horizontal,
//         child: SizedBox(
//           width: totalWidth,
//           child: Column(
//             children: [
//               // ── Header row với resize handle ──
//               Container(
//                 color: headerBg,
//                 child: Row(
//                   children: List.generate(
//                     _colDefs.length,
//                     (i) => _buildHeaderCell(
//                       _colDefs[i].$1,
//                       _colDefs[i].$2,
//                       i,
//                       _colDefs[i].$3,
//                       borderColor,
//                       isDark,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ── Data rows ──
//               Expanded(
//                 child:
//                     filteredData.isEmpty
//                         ? Center(
//                           child: Text(
//                             'No data',
//                             style: TextStyle(
//                               color: Colors.grey.shade500,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                         : Focus(
//                           onKeyEvent: (node, event) {
//                             if (event is KeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.keyC &&
//                                   HardwareKeyboard.instance.isControlPressed) {
//                                 _copySelectedRows();
//                                 return KeyEventResult.handled;
//                               }
//                               if (event.logicalKey ==
//                                   LogicalKeyboardKey.escape) {
//                                 setState(() => _selectedRows.clear());
//                                 return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                           child: Scrollbar(
//                             controller: _scrollV,
//                             thumbVisibility: true,
//                             child: ListView.builder(
//                               controller: _scrollV,
//                               itemCount: filteredData.length,
//                               itemBuilder:
//                                   (_, i) => _buildDataRow(
//                                     i,
//                                     borderColor,
//                                     isDark,
//                                     fmt,
//                                   ),
//                             ),
//                           ),
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableID(ThemeData theme) {
//     final isDark      = theme.brightness == Brightness.dark;
//     final borderColor = theme.dividerColor.withOpacity(0.4);
//     final headerBg    = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
//     final fmt         = NumberFormat('#,###');
//
//     // Lọc dataID theo cusID|shipBy nếu không phải All
//     final rows = widget.dataID; // đã được filter từ provider
//
//     const colLabels = ['VBELN', 'AUFNR', 'Cur_Process', 'Qty'];
//     const colWidths = [160.0, 160.0, 200.0, 100.0];
//
//     final totalWidth = colWidths.fold(0.0, (s, w) => s + w);
//
//     return Scrollbar(
//       controller: _scrollH,
//       thumbVisibility: true,
//       child: SingleChildScrollView(
//         controller: _scrollH,
//         scrollDirection: Axis.horizontal,
//         child: SizedBox(
//           width: totalWidth,
//           child: Column(children: [
//             // Header
//             Container(
//               color: headerBg,
//               child: Row(
//                 children: List.generate(colLabels.length, (i) => Container(
//                   width: colWidths[i],
//                   height: 40,
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: borderColor, width: 0.5),
//                   ),
//                   alignment: Alignment.centerLeft,
//                   child: Text(colLabels[i],
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                 )),
//               ),
//             ),
//
//             // Data rows
//             Expanded(
//               child: rows.isEmpty
//                   ? Center(child: Text('No data',
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 16)))
//                   : Scrollbar(
//                 controller: _scrollV,
//                 thumbVisibility: true,
//                 child: ListView.builder(
//                   controller: _scrollV,
//                   itemCount: rows.length,
//                   itemBuilder: (_, i) {
//                     final d    = rows[i];
//                     final isEven = i % 2 == 0;
//                     final rowBg = isEven
//                         ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
//                         : (isDark ? const Color(0xFF272727) : Colors.grey.shade50);
//
//                     Widget cell(String text, int idx, {bool isNum = false}) =>
//                         Container(
//                           width: colWidths[idx], height: 36,
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: rowBg,
//                             border: Border.all(color: borderColor, width: 0.5),
//                           ),
//                           alignment: isNum ? Alignment.centerRight : Alignment.centerLeft,
//                           child: SelectableText(text,
//                               style: const TextStyle(fontSize: 14), maxLines: 1),
//                         );
//
//                     return Row(children: [
//                       cell(d.vbeln, 0),
//                       cell(d.aufnr, 1),
//                       cell(d.curProcess, 2),
//                       cell(fmt.format(d.idQty), 3, isNum: true),
//                     ]);
//                   },
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//   // Header cell với drag resize
//   Widget _buildHeaderCell(
//     String label,
//     String key,
//     int colIdx,
//     bool isNumber,
//     Color borderColor,
//     bool isDark,
//   ) {
//     final values = <String>{};
//     for (final item in allData) {
//       final v = (item.toJson()[key] ?? '').toString();
//       if (v.isNotEmpty) values.add(v);
//     }
//     final isFiltered = _getSelected(key).isNotEmpty;
//     final width = _colWidths[colIdx];
//
//     return SizedBox(
//       width: width,
//       height: 48,
//       child: ClipRect(
//         child: Stack(
//           clipBehavior: Clip.hardEdge,
//           children: [
//             // Dropdown filter
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: borderColor, width: 0.5),
//               ),
//               child: MultiSelectDialogField<String>(
//                 buttonText: Text(
//                   label,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: isFiltered ? Colors.blueAccent : null,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//                 searchable: true,
//                 items:
//                     (values.toList()..sort())
//                         .map((v) => MultiSelectItem(v, v))
//                         .toList(),
//                 initialValue: _getSelected(key),
//                 buttonIcon: Icon(
//                   Icons.keyboard_arrow_down_outlined,
//                   size: 16,
//                   color: isFiltered ? Colors.blueAccent : Colors.grey,
//                 ),
//                 cancelText: const Text(
//                   'CANCEL',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 confirmText: const Text(
//                   'OK',
//                   style: TextStyle(
//                     color: Colors.blueAccent,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 chipDisplay: MultiSelectChipDisplay.none(),
//                 onConfirm:
//                     (results) => setState(() {
//                       _setSelected(key, results);
//                       _applyFilter();
//                       _hasInput = _checkHasInput();
//                     }),
//               ),
//             ),
//
//             // ── Resize handle — góc phải ──
//             Positioned(
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onHorizontalDragUpdate: (details) {
//                   setState(() {
//                     _colWidths[colIdx] = (_colWidths[colIdx] + details.delta.dx)
//                         .clamp(_minColWidth, 600.0);
//                   });
//                 },
//                 child: MouseRegion(
//                   cursor: SystemMouseCursors.resizeColumn,
//                   child: Container(
//                     width: 8,
//                     color: Colors.transparent,
//                     child: Center(
//                       child: Container(
//                         width: 2,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color:
//                               isDark
//                                   ? Colors.grey.shade600.withValues(alpha: 0.6)
//                                   : Colors.grey.shade400.withValues(alpha: 0.6),
//                           borderRadius: BorderRadius.circular(1),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Data row
//   Widget _buildDataRow(
//     int i,
//     Color borderColor,
//     bool isDark,
//     NumberFormat fmt,
//   ) {
//     final d = filteredData[i];
//     final isSelected = _selectedRows.contains(i);
//     final isEven = i % 2 == 0;
//     final rowBg =
//         isSelected
//             ? (isDark
//                 ? Colors.blueAccent.withOpacity(0.25)
//                 : Colors.blue.shade50)
//             : isEven
//             ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
//             : (isDark ? const Color(0xFF272727) : Colors.grey.shade50);
//     final j = d.toJson();
//
//     Widget txtCell(String key, int idx) => Container(
//       width: _colWidths[idx],
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: rowBg,
//         border: Border.all(color: borderColor, width: 0.5),
//       ),
//       alignment: Alignment.centerLeft,
//       child: SelectableText(
//         (j[key] ?? '').toString(),
//         style: const TextStyle(fontSize: 14),
//         maxLines: 1,
//       ),
//     );
//
//     Widget numCell(String key, double value, int idx) {
//       final isRemain = key.startsWith('remain');
//       Widget content =
//           isRemain && value > 0
//               ? Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color:
//                       isDark ? AppColors.remainBgDark : AppColors.remainBgLight,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: SelectableText(
//                   fmt.format(value),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//               )
//               : SelectableText(
//                 value == 0 ? '-' : fmt.format(value),
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: value == 0 ? Colors.grey.shade500 : null,
//                 ),
//               );
//
//       return Container(
//         width: _colWidths[idx],
//         height: 40,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: rowBg,
//           border: Border.all(color: borderColor, width: 0.5),
//         ),
//         alignment: Alignment.centerRight,
//         child: content,
//       );
//     }
//
//     return GestureDetector(
//       onTap: () => _handleRowTap(i, HardwareKeyboard.instance.isShiftPressed),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Row(
//           children: [
//             txtCell('ssd', 0),
//             txtCell('pickupTime', 1),
//             txtCell('cusID', 2),
//             txtCell('shipBy', 3),
//             txtCell('denk', 4),
//             txtCell('vbeln', 5),
//             txtCell('po', 6),
//             txtCell('div', 7),
//             txtCell('ferth', 8),
//             txtCell('roname', 9),
//             numCell('ex_Qty', d.exQty, 10),
//             numCell('fn_Qty', d.fnQty, 11),
//             numCell('remain_Qty', d.remainQty, 12),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Footer ────────────────────────────────────────────────────────────────
//
//   Widget _buildFooter(BuildContext context) => Row(
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       FilledButton.icon(
//         icon: const Icon(Icons.close, size: 18, color: Colors.white),
//         label: const Text(
//           'Close',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         style: FilledButton.styleFrom(
//           backgroundColor: Colors.deepOrange,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//         ),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//     ],
//   );
//
//   // ── Excel ─────────────────────────────────────────────────────────────────
//
//   Uint8List _buildExcel(List<RemainTableDetailModel> data) {
//     final excel = xl.Excel.createExcel();
//     final sheet = excel['Sheet1'] as xl.Sheet;
//     sheet.appendRow([
//       'SSD',
//       'PickupTime',
//       'CusID',
//       'ShipBy',
//       'DENK',
//       'VBELN',
//       'PO',
//       'Div',
//       'FERTH',
//       'RONAME',
//       'Ex Qty',
//       'Fn Qty',
//       'Remain Qty',
//     ]);
//     for (final item in data) {
//       final j = item.toJson();
//       sheet.appendRow([
//         j['ssd'],
//         j['pickupTime'],
//         j['cusID'],
//         j['shipBy'],
//         j['denk'],
//         j['vbeln'],
//         j['po'],
//         j['div'],
//         j['ferth'],
//         j['roname'],
//         item.exQty,
//         item.fnQty,
//         item.remainQty,
//       ]);
//     }
//     return Uint8List.fromList(excel.encode()!);
//   }
//
//   void _downloadExcel(Uint8List bytes, String fileName) {
//     final blob = html.Blob([bytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     html.AnchorElement(href: url)
//       ..setAttribute('download', fileName)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   }
//
// }
//
// class _PoIdToggle extends StatelessWidget {
//   final bool showPO;
//   final ValueChanged<bool> onToggle;
//   const _PoIdToggle({required this.showPO, required this.onToggle});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     const double w = 64, h = 26, thumbW = 30, margin = 3;
//     final thumbColor = showPO ? Colors.blueAccent : const Color(0xFFE53935);
//
//     return GestureDetector(
//       onTap: () => onToggle(!showPO),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: w, height: h,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(h / 2),
//             color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(h / 2),
//             child: Stack(children: [
//               // Sliding thumb
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 top: margin,
//                 left: showPO ? margin : (w - thumbW - margin),
//                 child: Container(
//                   width: thumbW, height: h - margin * 2,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular((h - margin * 2) / 2),
//                     color: thumbColor,
//                     boxShadow: [BoxShadow(
//                         color: thumbColor.withOpacity(0.4), blurRadius: 4)],
//                   ),
//                 ),
//               ),
//               // Labels
//               Row(children: [
//                 Expanded(child: Center(child: Text('PO',
//                     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
//                         color: showPO ? Colors.white : Colors.grey.shade500)))),
//                 Expanded(child: Center(child: Text('ID',
//                     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
//                         color: !showPO ? Colors.white : Colors.grey.shade500)))),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ma_visualization/Model/RemainTableDetailModel.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart'
    show MultiSelectDialogField;
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:ma_visualization/Model/RemainTableDetailIDModel.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../Common/AppColors.dart';
import '../Provider/RemainTableProvider.dart';

class RemainTableDetailPopup extends StatefulWidget {
  final String nameChart;
  final String title;
  final List<RemainTableDetailModel> data;
  final List<RemainTableDetailIDModel> dataID;
  final String div;
  final String date;
  final String cusID;
  final String shipBy;

  const RemainTableDetailPopup({
    Key? key,
    required this.nameChart,
    required this.title,
    required this.data,
    required this.dataID,
    required this.div,
    required this.date,
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

  bool _hasInput     = false;
  bool _showPOView   = true;
  bool _isLoadingID  = false;
  DateTime _selectedDate = DateTime.now();

  List<RemainTableDetailModel>   allData      = [];
  List<RemainTableDetailModel>   filteredData = [];
  List<RemainTableDetailIDModel> _cachedIDs   = [];

  static const _colDefs = [
    ('SSD', 'ssd', false),
    ('PickupTime', 'pickupTime', false),
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

  late List<double> _colWidths;
  static const _defaultWidths = [
    130.0, 160.0, 100.0, 90.0, 80.0, 120.0,
    200.0, 70.0, 140.0, 220.0, 90.0, 90.0, 120.0,
  ];
  static const _minColWidth = 50.0;

  List<String>? selSsd, selPickupTime, selCusID, selShipBy, selDenk;
  List<String>? selVbeln, selPo, selDiv, selFerth, selRoname;
  List<String>? selExQty, selFnQty, selRemainQty;

  final Map<String, List<RemainTableDetailModel>> _cache = {};

  final Set<int> _selectedRows = {};
  int? _lastSelectedRow;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _colWidths   = List.from(_defaultWidths);
    allData      = widget.data;
    _showPOView  = true;
    filteredData = widget.data;
    if (widget.dataID.isNotEmpty) {
      _cachedIDs = widget.dataID;
    }
    _filterController.addListener(() {
      if (!mounted) return;
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

  // ── Toggle PO / ID ────────────────────────────────────────────────────────
  Future<void> _switchView(bool showPO) async {
    if (!showPO && _cachedIDs.isEmpty) {
      // ✅ Set loading trước khi await
      if (!mounted) return;
      setState(() => _isLoadingID = true);

      try {
        final provider = context.read<RemainTableProvider>();
        final ids = await provider.fetchDetailID(
          div:    widget.div,
          date:   widget.date,
          cusID:  widget.cusID.isEmpty ? 'All' : widget.cusID,
          shipBy: widget.shipBy.isEmpty ? 'All' : widget.shipBy,
        );

        // ✅ Check mounted sau mỗi await — tránh setState after dispose
        if (!mounted) return;

        setState(() {
          _cachedIDs   = ids;
          _showPOView  = false;
          _isLoadingID = false;
          _selectedRows.clear();
          _hasInput    = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoadingID = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ID data: $e')),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        _showPOView = showPO;
        _selectedRows.clear();
        _hasInput   = false;
      });
      if (showPO) _resetFilter();
    }
  }

  Future<void> _copySelectedRows() async {
    if (_selectedRows.isEmpty) return;
    final rows = _selectedRows.toList()..sort();
    final buf  = StringBuffer();
    buf.writeln(_colDefs.map((c) => c.$1).join('\t'));
    for (final i in rows) {
      final j = filteredData[i].toJson();
      buf.writeln(_colDefs.map((c) => (j[c.$2] ?? '').toString()).join('\t'));
    }
    final text = buf.toString().trimRight();

    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {
      final ta = html.TextAreaElement()
        ..value = text
        ..style.position = 'fixed'
        ..style.opacity  = '0';
      html.document.body!.append(ta);
      ta.select();
      html.document.execCommand('copy');
      ta.remove();
    }

    if (!mounted) return;
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _handleRowTap(int index, bool shiftKey) {
    setState(() {
      if (shiftKey && _lastSelectedRow != null) {
        final from  = _lastSelectedRow!;
        final to    = index;
        final start = from < to ? from : to;
        final end   = from < to ? to : from;
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

  // ── Load by date picker ───────────────────────────────────────────────────
  Future<void> _loadData(DateTime date) async {
    final dateStr  = DateFormat('yyyy-MM-dd').format(date);
    final cacheKey = '$dateStr-${widget.title}';

    if (_cache.containsKey(cacheKey)) {
      if (!mounted) return;
      setState(() { allData = filteredData = _cache[cacheKey]!; });
      _applyFilter();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final provider = context.read<RemainTableProvider>();
    final data = await provider.fetchDetail(
      div:    widget.div,
      date:   dateStr,
      cusID:  widget.cusID.isEmpty ? 'All' : widget.cusID,
      shipBy: widget.shipBy.isEmpty ? 'All' : widget.shipBy,
    );

    // ✅ Check mounted sau await trước khi pop dialog và setState
    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {
      allData          = data;
      filteredData     = data;
      _cache[cacheKey] = data;
      _cachedIDs       = []; // reset ID cache khi đổi ngày
      if (!_showPOView) _showPOView = true;
    });
    _applyFilter();
  }

  // ── Filter helpers ────────────────────────────────────────────────────────
  bool _checkHasInput() =>
      selSsd != null || selPickupTime != null || selCusID != null ||
          selShipBy != null || selDenk != null || selVbeln != null ||
          selPo != null || selDiv != null || selFerth != null ||
          selRoname != null || selExQty != null || selFnQty != null ||
          selRemainQty != null || _filterController.text.trim().isNotEmpty;

  List<String> _getSelected(String key) {
    switch (key) {
      case 'ssd':        return selSsd        ?? [];
      case 'pickupTime': return selPickupTime ?? [];
      case 'cusID':      return selCusID      ?? [];
      case 'shipBy':     return selShipBy     ?? [];
      case 'denk':       return selDenk       ?? [];
      case 'vbeln':      return selVbeln      ?? [];
      case 'po':         return selPo         ?? [];
      case 'div':        return selDiv        ?? [];
      case 'ferth':      return selFerth      ?? [];
      case 'roname':     return selRoname     ?? [];
      case 'ex_Qty':     return selExQty      ?? [];
      case 'fn_Qty':     return selFnQty      ?? [];
      case 'remain_Qty': return selRemainQty  ?? [];
      default:           return [];
    }
  }

  void _setSelected(String key, List<String> results) {
    final v = results.isEmpty ? null : results;
    switch (key) {
      case 'ssd':        selSsd        = v; break;
      case 'pickupTime': selPickupTime = v; break;
      case 'cusID':      selCusID      = v; break;
      case 'shipBy':     selShipBy     = v; break;
      case 'denk':       selDenk       = v; break;
      case 'vbeln':      selVbeln      = v; break;
      case 'po':         selPo         = v; break;
      case 'div':        selDiv        = v; break;
      case 'ferth':      selFerth      = v; break;
      case 'roname':     selRoname     = v; break;
      case 'ex_Qty':     selExQty      = v; break;
      case 'fn_Qty':     selFnQty      = v; break;
      case 'remain_Qty': selRemainQty  = v; break;
    }
  }

  void _applyFilter() {
    if (!mounted) return;
    final query  = _filterController.text.trim().toLowerCase();
    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    setState(() {
      filteredData = allData.where((item) {
        final j = item.toJson();
        bool textMatch = true;
        if (tokens.isNotEmpty) {
          final searchable = [
            'ssd', 'pickupTime', 'cusID', 'shipBy', 'denk',
            'vbeln', 'po', 'div', 'ferth', 'roname',
          ].map((k) => (j[k] ?? '').toString().toLowerCase()).join(' ');
          textMatch = tokens.every((t) => searchable.contains(t));
        }
        bool dropMatch = true;
        for (final col in _colDefs) {
          final sel = _getSelected(col.$2);
          if (sel.isNotEmpty) {
            final val = (j[col.$2] ?? '').toString();
            if (!sel.contains(val)) { dropMatch = false; break; }
          }
        }
        return textMatch && dropMatch;
      }).toList();
    });
  }

  void _resetFilter() {
    if (!mounted) return;
    setState(() {
      _filterController.clear();
      selSsd = selPickupTime = selCusID = selShipBy = selDenk =
          selVbeln = selPo = selDiv = selFerth = selRoname =
          selExQty = selFnQty = selRemainQty = null;
      filteredData = allData;
      _hasInput    = false;
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
          maxWidth:  MediaQuery.of(context).size.width  - 32,
          maxHeight: MediaQuery.of(context).size.height - 32,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoadingID
                    ? const Center(child: CircularProgressIndicator())
                    : _showPOView
                    ? _buildTable(theme)
                    : _buildTableID(theme),
              ),
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
    final isDark         = theme.brightness == Brightness.dark;
    final totalExQty     = filteredData.fold<double>(0, (s, e) => s + e.exQty);
    final totalRemainQty = filteredData.fold<double>(0, (s, e) => s + e.remainQty);
    final totalRemainPO  = filteredData.where((e) => e.remainQty > 0).length;
    final fmt            = NumberFormat('#,###');

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
                      color: Colors.blueAccent, fontWeight: FontWeight.bold,
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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      side: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (!mounted) return;
                      if (picked != null && picked != _selectedDate) {
                        setState(() => _selectedDate = picked);
                        await _loadData(picked);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _PoIdToggle(showPO: _showPOView, onToggle: _switchView),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Reset column widths',
                    child: IconButton(
                      icon: const Icon(Icons.view_column_outlined, size: 20),
                      onPressed: () => setState(
                              () => _colWidths = List.from(_defaultWidths)),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _statChip('Total PO',   '${filteredData.length}',   Colors.blueAccent,   isDark),
                const SizedBox(width: 10),
                _statChip('Total Qty',  fmt.format(totalExQty),     Colors.blueAccent,   isDark),
                const SizedBox(width: 10),
                _statChip('Remain PO',  fmt.format(totalRemainPO),  AppColors.remainLight, isDark, highlight: true),
                const SizedBox(width: 10),
                _statChip('Remain Qty', fmt.format(totalRemainQty), AppColors.remainLight, isDark, highlight: true),
                const SizedBox(width: 16),
                if (_selectedRows.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: _isCopied ? Colors.green.shade700 : Colors.blueAccent.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FilledButton.icon(
                        icon: Icon(
                          _isCopied ? Icons.check_circle_outline : Icons.copy,
                          size: 18, color: Colors.white,
                        ),
                        label: Text(
                          _isCopied
                              ? 'Copied ${_selectedRows.length} row(s)!'
                              : 'Copy (${_selectedRows.length})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor:     Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _isCopied ? null : _copySelectedRows,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.white),
                  label: const Text('Clear',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _hasInput ? Colors.red.shade700 : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _resetFilter,
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                  label: const Text('Export Excel',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _downloadExcel(
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
            suffixIcon: _filterController.text.isNotEmpty
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

  // ── Stat chip ─────────────────────────────────────────────────────────────
  Widget _statChip(String label, String value, Color valueColor, bool isDark,
      {bool highlight = false}) {
    final bgColor = highlight
        ? (isDark
        ? AppColors.remainBgDark.withValues(alpha: 0.15)
        : AppColors.remainBgLight.withValues(alpha: 0.3))
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
    final borderColor = highlight
        ? AppColors.remainBorderDark
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade300);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  // ── PO Table ──────────────────────────────────────────────────────────────
  Widget _buildTable(ThemeData theme) {
    final isDark      = theme.brightness == Brightness.dark;
    final borderColor = theme.dividerColor.withValues(alpha: 0.4);
    final headerBg    = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
    final fmt         = NumberFormat('#,###');
    final totalWidth  = _colWidths.fold(0.0, (s, w) => s + w);

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
              Container(
                color: headerBg,
                child: Row(
                  children: List.generate(
                    _colDefs.length,
                        (i) => _buildHeaderCell(
                      _colDefs[i].$1, _colDefs[i].$2, i,
                      _colDefs[i].$3, borderColor, isDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                    child: Text('No data',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 16)))
                    : Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.keyC &&
                          HardwareKeyboard.instance.isControlPressed) {
                        _copySelectedRows();
                        return KeyEventResult.handled;
                      }
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
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
                      itemBuilder: (_, i) =>
                          _buildDataRow(i, borderColor, isDark, fmt),
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

  // ── ID Table ──────────────────────────────────────────────────────────────
  Widget _buildTableID(ThemeData theme) {
    final isDark      = theme.brightness == Brightness.dark;
    final borderColor = theme.dividerColor.withOpacity(0.4);
    final headerBg    = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
    final fmt         = NumberFormat('#,###');

    const colLabels = ['SSD', 'CusID', 'ShipBy', 'DENK', 'VBELN',
        'PO', 'AUFNR', 'RONAME', 'currentProcess', 'ID_Qty'];
    const colWidths = [120.0, 120.0, 120.0, 120.0, 160.0, 200.0, 160.0, 250.0, 200.0, 100.0];
    final totalWidth = colWidths.fold(0.0, (s, w) => s + w);

    return Scrollbar(
      controller: _scrollH,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollH,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(children: [
            Container(
              color: headerBg,
              child: Row(
                children: List.generate(
                  colLabels.length,
                      (i) => Container(
                    width: colWidths[i], height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 0.5)),
                    alignment: Alignment.centerLeft,
                    child: Text(colLabels[i],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _cachedIDs.isEmpty
                  ? Center(
                  child: Text('No data',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16)))
                  : Scrollbar(
                controller: _scrollV,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollV,
                  itemCount: _cachedIDs.length,
                  itemBuilder: (_, i) {
                    final d      = _cachedIDs[i];
                    final isEven = i % 2 == 0;
                    final rowBg  = isEven
                        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                        : (isDark ? const Color(0xFF272727) : Colors.grey.shade50);

                    Widget cell(String text, int idx, {bool isNum = false}) =>
                        Container(
                          width: colWidths[idx], height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color:  rowBg,
                              border: Border.all(
                                  color: borderColor, width: 0.5)),
                          alignment: isNum
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: SelectableText(text,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1),
                        );

                    return Row(children: [
                      cell(d.ssd,        0),                          // SSD
                      cell(d.cusID,      1),                          // CusID
                      cell(d.shipBy,     2),                          // ShipBy
                      cell(d.denk,       3),                          // DENK
                      cell(d.vbeln,      4),                          // VBELN
                      cell(d.po,         5),                          // PO
                      cell(d.aufnr,      6),                          // AUFNR
                      cell(d.roName,     7),                          // RONAME
                      cell(d.curProcess, 8),                          // Cur_Process
                      cell(fmt.format(d.idQty), 9, isNum: true),      // Qty
                    ]);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Header cell với resize ────────────────────────────────────────────────
  Widget _buildHeaderCell(String label, String key, int colIdx, bool isNumber,
      Color borderColor, bool isDark) {
    final values     = <String>{};
    for (final item in allData) {
      final v = (item.toJson()[key] ?? '').toString();
      if (v.isNotEmpty) values.add(v);
    }
    final isFiltered = _getSelected(key).isNotEmpty;
    final width      = _colWidths[colIdx];

    return SizedBox(
      width: width, height: 48,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.5)),
              child: MultiSelectDialogField<String>(
                buttonText: Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14,
                      color: isFiltered ? Colors.blueAccent : null,
                    ),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                searchable: true,
                items: (values.toList()..sort())
                    .map((v) => MultiSelectItem(v, v))
                    .toList(),
                initialValue: _getSelected(key),
                buttonIcon: Icon(Icons.keyboard_arrow_down_outlined,
                    size: 16,
                    color: isFiltered ? Colors.blueAccent : Colors.grey),
                cancelText: const Text('CANCEL',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                confirmText: const Text('OK',
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                chipDisplay: MultiSelectChipDisplay.none(),
                onConfirm: (results) => setState(() {
                  _setSelected(key, results);
                  _applyFilter();
                  _hasInput = _checkHasInput();
                }),
              ),
            ),
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _colWidths[colIdx] =
                        (_colWidths[colIdx] + details.delta.dx)
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
                        width: 2, height: 20,
                        decoration: BoxDecoration(
                          color: isDark
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
        ),
      ),
    );
  }

  // ── Data row ──────────────────────────────────────────────────────────────
  Widget _buildDataRow(int i, Color borderColor, bool isDark, NumberFormat fmt) {
    final d          = filteredData[i];
    final isSelected = _selectedRows.contains(i);
    final isEven     = i % 2 == 0;
    final rowBg      = isSelected
        ? (isDark ? Colors.blueAccent.withOpacity(0.25) : Colors.blue.shade50)
        : isEven
        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
        : (isDark ? const Color(0xFF272727) : Colors.grey.shade50);
    final j = d.toJson();

    Widget txtCell(String key, int idx) => Container(
      width: _colWidths[idx], height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color:  rowBg,
          border: Border.all(color: borderColor, width: 0.5)),
      alignment: Alignment.centerLeft,
      child: SelectableText(
        (j[key] ?? '').toString(),
        style: const TextStyle(fontSize: 14), maxLines: 1,
      ),
    );

    Widget numCell(String key, double value, int idx) {
      final isRemain = key.startsWith('remain');
      Widget content = isRemain && value > 0
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.remainBgDark : AppColors.remainBgLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: SelectableText(fmt.format(value),
            style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14,
              color: Colors.black87,
            )),
      )
          : SelectableText(
        value == 0 ? '-' : fmt.format(value),
        style: TextStyle(
            fontSize: 14,
            color: value == 0 ? Colors.grey.shade500 : null),
      );

      return Container(
        width: _colWidths[idx], height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color:  rowBg,
            border: Border.all(color: borderColor, width: 0.5)),
        alignment: Alignment.centerRight,
        child: content,
      );
    }

    return GestureDetector(
      onTap: () => _handleRowTap(i, HardwareKeyboard.instance.isShiftPressed),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(children: [
          txtCell('ssd', 0),
          txtCell('pickupTime', 1),
          txtCell('cusID', 2),
          txtCell('shipBy', 3),
          txtCell('denk', 4),
          txtCell('vbeln', 5),
          txtCell('po', 6),
          txtCell('div', 7),
          txtCell('ferth', 8),
          txtCell('roname', 9),
          numCell('ex_Qty',     d.exQty,     10),
          numCell('fn_Qty',     d.fnQty,     11),
          numCell('remain_Qty', d.remainQty, 12),
        ]),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FilledButton.icon(
        icon: const Icon(Icons.close, size: 18, color: Colors.white),
        label: const Text('Close',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      'SSD', 'PickupTime', 'CusID', 'ShipBy', 'DENK', 'VBELN',
      'PO', 'Div', 'FERTH', 'RONAME', 'Ex Qty', 'Fn Qty', 'Remain Qty',
    ]);
    for (final item in data) {
      final j = item.toJson();
      sheet.appendRow([
        j['ssd'], j['pickupTime'], j['cusID'], j['shipBy'], j['denk'],
        j['vbeln'], j['po'], j['div'], j['ferth'], j['roname'],
        item.exQty, item.fnQty, item.remainQty,
      ]);
    }
    return Uint8List.fromList(excel.encode()!);
  }

  void _downloadExcel(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url  = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

// ── PO / ID Toggle ────────────────────────────────────────────────────────────
class _PoIdToggle extends StatelessWidget {
  final bool showPO;
  final Future<void> Function(bool) onToggle;

  const _PoIdToggle({required this.showPO, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    const double w   = 64, h = 26, thumbW = 30, margin = 3;
    final thumbColor = showPO ? Colors.blueAccent : const Color(0xFFE53935);

    return GestureDetector(
      onTap: () => onToggle(!showPO),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: w, height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(h / 2),
            child: Stack(children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                top: margin,
                left: showPO ? margin : (w - thumbW - margin),
                child: Container(
                  width: thumbW, height: h - margin * 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular((h - margin * 2) / 2),
                    color: thumbColor,
                    boxShadow: [BoxShadow(
                        color: thumbColor.withOpacity(0.4), blurRadius: 4)],
                  ),
                ),
              ),
              Row(children: [
                Expanded(child: Center(child: Text('PO',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: showPO ? Colors.white : Colors.grey.shade500,
                    )))),
                Expanded(child: Center(child: Text('ID',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: !showPO ? Colors.white : Colors.grey.shade500,
                    )))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}