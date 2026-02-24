import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pdf/pdf.dart';

class DynamicTable extends StatefulWidget {
  final List<String> headers;
  final List<List<String>>? rows;
  final List<Map<String, dynamic>>? data;

  final List<int>? colSpans;
  final List<TextAlign>? alignments;
  final String? totalValue;
  final bool showTotal;
  final TextStyle headerStyle;
  final TextStyle cellStyle;
  final Color? headerBgColor;
  final Color? altRowColor;

  final bool isScrollable;
  final bool clipText;
  final double? columnWidth;
  final String? groupBy;
  final TextStyle? groupHeaderStyle;
  final Color? groupHeaderBgColor;
  final Color? groupRowColor;
  final Function(int, dynamic)? onRowTap;

  const DynamicTable({
    super.key,
    required this.headers,
    this.rows,
    this.data,
    this.colSpans,
    this.alignments,
    this.totalValue,
    this.showTotal = false,
    required this.headerStyle,
    required this.cellStyle,
    this.headerBgColor,
    this.altRowColor,
    this.onRowTap,
    this.isScrollable = false,
    this.clipText = true,
    this.columnWidth,
    this.groupBy,
    this.groupHeaderStyle,
    this.groupHeaderBgColor,
    this.groupRowColor,
  }) : assert(
         rows != null || data != null,
         "Either rows or data must be provided",
       );

  @override
  State<DynamicTable> createState() => _DynamicTableState();
}

enum SortState { ascending, descending, none }

class _DynamicTableState extends State<DynamicTable> {
  late List<List<String>> sortedRows;
  late List<List<String>> originalRows;
  List<Map<String, dynamic>>? sortedData;
  List<Map<String, dynamic>>? originalData;
  int? sortColumnIndex;
  SortState sortState = SortState.none;

  @override
  void initState() {
    super.initState();
    _handleData();
  }

  void _handleData() {
    List<List<String>> effectiveRows = [];
    if (widget.data != null) {
      originalData = List.from(widget.data!);
      // If we have data maps, we need to extract values based on headers.
      // However, if the headers were parameterized/changed, we might fail to find the original keys.
      // A better approach is to use the original keys if they are available,
      // but here we must rely on widget.headers.

      effectiveRows = widget.data!.map((map) {
        // Try to match header to map key flexibly
        return widget.headers.map((h) {
          if (map.containsKey(h)) return map[h]?.toString() ?? "";

          // Try lowercase/snake_case matching as a fallback
          String snakeKey = h.toLowerCase().replaceAll(" ", "_");
          if (map.containsKey(snakeKey)) return map[snakeKey]?.toString() ?? "";

          // Try find by case-insensitive match
          for (var key in map.keys) {
            if (key.toLowerCase() == h.toLowerCase()) {
              return map[key]?.toString() ?? "";
            }
          }

          return map[h]?.toString() ?? "";
        }).toList();
      }).toList();
    } else if (widget.rows != null) {
      effectiveRows = List.from(widget.rows!);
      originalData = null;
    }

    originalRows = List.from(effectiveRows);
    sortedRows = List.from(effectiveRows);
    sortedData = originalData != null ? List.from(originalData!) : null;
  }

  @override
  void didUpdateWidget(covariant DynamicTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rows != oldWidget.rows || widget.data != oldWidget.data) {
      _handleData();
      _applySort();
    }
  }

  void _applySort() {
    setState(() {
      if (sortColumnIndex == null || sortState == SortState.none) {
        sortedRows = List.from(originalRows);
        sortedData = originalData != null ? List.from(originalData!) : null;
      } else {
        final ascending = sortState == SortState.ascending;

        // We need to sort both rows and data in sync
        List<int> indices = List.generate(originalRows.length, (i) => i);
        indices.sort((idxA, idxB) {
          final valA = originalRows[idxA][sortColumnIndex!];
          final valB = originalRows[idxB][sortColumnIndex!];

          final numA = num.tryParse(valA);
          final numB = num.tryParse(valB);

          int result;
          if (numA != null && numB != null) {
            result = numA.compareTo(numB);
          } else {
            result = valA.toLowerCase().compareTo(valB.toLowerCase());
          }

          return ascending ? result : -result;
        });

        sortedRows = indices.map((i) => originalRows[i]).toList();
        if (originalData != null) {
          sortedData = indices.map((i) => originalData![i]).toList();
        }
      }
    });
  }

  void sortColumn(int columnIndex) {
    if (sortColumnIndex != columnIndex) {
      sortColumnIndex = columnIndex;
      sortState = SortState.ascending;
    } else {
      switch (sortState) {
        case SortState.none:
          sortState = SortState.ascending;
          break;
        case SortState.ascending:
          sortState = SortState.descending;
          break;
        case SortState.descending:
          sortState = SortState.none;
          break;
      }
    }
    _applySort();
  }

  @override
  Widget build(BuildContext context) {
    final headerBgColor = widget.headerBgColor ?? colorManager.primaryColor;
    final altRowColor =
        widget.altRowColor ?? colorManager.primaryColor.withOpacity(.1);

    // Default colSpans and alignments
    final colSpans = widget.colSpans ?? List.filled(widget.headers.length, 1);
    final alignments =
        widget.alignments ??
        List.filled(widget.headers.length, TextAlign.center);

    final overflow = widget.clipText
        ? TextOverflow.ellipsis
        : TextOverflow.visible;
    final maxLines = widget.clipText ? 1 : (widget.isScrollable ? 1 : null);
    final softWrap = widget.clipText
        ? false
        : (widget.isScrollable ? false : true);

    // Standard Non-Scrollable Layout (Flex based)
    if (!widget.isScrollable) {
      return Column(
        children: [
          // Header Row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
            decoration: BoxDecoration(color: headerBgColor),
            child: Row(
              children: List.generate(widget.headers.length, (i) {
                Icon? icon;
                if (sortColumnIndex == i) {
                  if (sortState == SortState.ascending) {
                    icon = const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: Colors.white,
                    );
                  } else if (sortState == SortState.descending) {
                    icon = const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: Colors.white,
                    );
                  }
                }

                return Expanded(
                  flex: 3 * (i < colSpans.length ? colSpans[i] : 1),
                  child: InkWell(
                    onTap: () => sortColumn(i),
                    child: Row(
                      mainAxisAlignment: alignments[i] == TextAlign.start
                          ? MainAxisAlignment.start
                          : alignments[i] == TextAlign.end
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.headers[i],
                            style: widget.headerStyle,
                            maxLines: maxLines,
                            softWrap: softWrap,
                            overflow: overflow,
                          ),
                        ),
                        if (icon != null) icon,
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Data Rows with Grouping
          ...() {
            List<Widget> children = [];
            String? lastGroup;
            int groupIndex =
                (widget.groupBy != null && widget.groupBy!.isNotEmpty)
                ? widget.headers.indexOf(widget.groupBy!)
                : -1;

            for (int index = 0; index < sortedRows.length; index++) {
              final row = sortedRows[index];

              if (groupIndex != -1) {
                final currentGroup = row[groupIndex];
                if (currentGroup != lastGroup) {
                  // Add Group Header
                  children.add(
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12,
                      ),
                      color:
                          widget.groupRowColor ??
                          widget.groupHeaderBgColor ??
                          headerBgColor.withOpacity(0.1),
                      child: Text(
                        currentGroup,
                        style:
                            widget.groupHeaderStyle ??
                            widget.headerStyle.copyWith(
                              color: headerBgColor,
                              fontSize: 14,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  lastGroup = currentGroup;
                }
              }

              final bgColor = index % 2 == 0 ? altRowColor : null;
              children.add(
                InkWell(
                  onTap: widget.onRowTap != null
                      ? () => widget.onRowTap!(
                          index,
                          sortedData != null ? sortedData![index] : row,
                        )
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(color: bgColor),
                    child: Row(
                      children: List.generate(row.length, (i) {
                        return Expanded(
                          flex: 3 * (i < colSpans.length ? colSpans[i] : 1),
                          child: Text(
                            row[i],
                            style: widget.cellStyle,
                            textAlign: alignments[i],
                            maxLines: maxLines,
                            softWrap: softWrap,
                            overflow: overflow,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            }
            return children;
          }(),

          // Total Row
          if (widget.showTotal && widget.totalValue != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 12,
              ),
              decoration: BoxDecoration(color: headerBgColor),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text("Total", style: widget.headerStyle),
                  ),
                  Expanded(
                    flex: (widget.headers.length - 1) * 3,
                    child: Text(
                      widget.totalValue!,
                      style: widget.headerStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Scrollable Layout (Table based for intrinsic sizing)
    Widget buildTableCell(
      String text,
      TextAlign textAlign, {
      bool isHeader = false,
      VoidCallback? onTap,
    }) {
      Widget content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Text(
          text,
          style: isHeader ? widget.headerStyle : widget.cellStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          softWrap: softWrap,
          overflow: overflow,
        ),
      );

      if (onTap != null) {
        return InkWell(onTap: onTap, child: content);
      }
      return content;
    }

    List<TableRow> tableRows = [];

    // Header Row
    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: headerBgColor),
        children: List.generate(widget.headers.length, (i) {
          Icon? icon;
          if (sortColumnIndex == i) {
            if (sortState == SortState.ascending) {
              icon = const Icon(
                Icons.arrow_upward,
                size: 16,
                color: Colors.white,
              );
            } else if (sortState == SortState.descending) {
              icon = const Icon(
                Icons.arrow_downward,
                size: 16,
                color: Colors.white,
              );
            }
          }

          return InkWell(
            onTap: () => sortColumn(i),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: alignments[i] == TextAlign.start
                  ? MainAxisAlignment.start
                  : alignments[i] == TextAlign.end
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.center,
              children: [
                buildTableCell(
                  widget.headers[i],
                  alignments[i],
                  isHeader: true,
                ),
                if (icon != null) icon,
              ],
            ),
          );
        }),
      ),
    );

    // Data Rows with Grouping
    String? lastGroup;
    int groupIndex = (widget.groupBy != null && widget.groupBy!.isNotEmpty)
        ? widget.headers.indexOf(widget.groupBy!)
        : -1;

    for (int index = 0; index < sortedRows.length; index++) {
      final row = sortedRows[index];

      if (groupIndex != -1) {
        final currentGroup = row[groupIndex];
        if (currentGroup != lastGroup) {
          tableRows.add(
            TableRow(
              decoration: BoxDecoration(
                color:
                    widget.groupRowColor ??
                    widget.groupHeaderBgColor ??
                    headerBgColor.withOpacity(0.1),
              ),
              children: List.generate(widget.headers.length, (i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currentGroup,
                      style:
                          widget.groupHeaderStyle ??
                          widget.headerStyle.copyWith(
                            color: headerBgColor,
                            fontSize: 14,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          );
          lastGroup = currentGroup;
        }
      }

      final bgColor = index % 2 == 0 ? altRowColor : null;

      tableRows.add(
        TableRow(
          decoration: BoxDecoration(color: bgColor),
          children: List.generate(row.length, (i) {
            return buildTableCell(
              row[i],
              alignments[i],
              onTap: widget.onRowTap != null
                  ? () => widget.onRowTap!(
                      index,
                      sortedData != null ? sortedData![index] : row,
                    )
                  : null,
            );
          }),
        ),
      );
    }

    // Total Row
    if (widget.showTotal && widget.totalValue != null) {
      tableRows.add(
        TableRow(
          decoration: BoxDecoration(color: headerBgColor),
          children: [
            buildTableCell("Total", TextAlign.start, isHeader: true),
            ...List.generate(
              widget.headers.length - 2,
              (i) => const SizedBox(),
            ),
            buildTableCell(widget.totalValue!, TextAlign.end, isHeader: true),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                for (int i = 0; i < widget.headers.length; i++)
                  i: const IntrinsicColumnWidth(),
              },
              children: tableRows,
            ),
          ),
        );
      },
    );
  }
}

class PdfDynamicTable {
  static pw.Widget build({
    required List<String> headers,
    required List<List<String>> rows,

    List<TextAlign>? alignments,
    List<int>? colSpans,

    bool showTotal = false,
    String? totalValue,

    String? groupBy,
    pw.TextStyle? headerStyle,
    pw.TextStyle? cellStyle,
    pw.TextStyle? groupHeaderStyle,

    PdfColor? headerBgColor,
    PdfColor? altRowColor,
    PdfColor? groupHeaderBgColor,
  }) {
    final headerTextStyle =
        headerStyle ??
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

    final cellTextStyle = cellStyle ?? pw.TextStyle(fontSize: 9);

    final headerBackground = headerBgColor ?? PdfColors.grey300;
    final alternateRowColor = altRowColor ?? PdfColors.grey100;

    final effectiveAlignments =
        alignments ?? List.filled(headers.length, TextAlign.center);

    int groupIndex = groupBy != null ? headers.indexOf(groupBy) : -1;

    String? lastGroup;

    return pw.Table(
      columnWidths: {
        for (int i = 0; i < headers.length; i++) i: const pw.FlexColumnWidth(),
      },
      children: [
        /// HEADER ROW
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerBackground),
          children: headers.asMap().entries.map((entry) {
            final i = entry.key;
            final h = entry.value;
            return pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                h,
                style: headerTextStyle,
                textAlign: _mapAlign(effectiveAlignments[i]), // Apply here too!
              ),
            );
          }).toList(),
        ),

        /// DATA ROWS
        ...rows.asMap().entries.expand((entry) {
          final index = entry.key;
          final row = entry.value;

          List<pw.TableRow> tableRows = [];

          /// GROUP HEADER
          if (groupIndex != -1) {
            final currentGroup = row[groupIndex];
            if (currentGroup != lastGroup) {
              tableRows.add(
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: groupHeaderBgColor ?? PdfColors.grey200,
                  ),
                  children: List.generate(headers.length, (i) {
                    return i == 0
                        ? pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              currentGroup,
                              style:
                                  groupHeaderStyle ??
                                  headerTextStyle.copyWith(fontSize: 10),
                            ),
                          )
                        : pw.SizedBox();
                  }),
                ),
              );
              lastGroup = currentGroup;
            }
          }

          /// DATA ROW
          tableRows.add(
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: index.isEven ? alternateRowColor : null,
              ),
              children: List.generate(row.length, (i) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    row[i],
                    style: cellTextStyle,
                    textAlign: _mapAlign(effectiveAlignments[i]),
                  ),
                );
              }),
            ),
          );

          return tableRows;
        }),

        /// TOTAL ROW
        if (showTotal && totalValue != null)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: headerBackground),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Total", style: headerTextStyle),
              ),
              ...List.generate(headers.length - 2, (_) => pw.SizedBox()),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  totalValue,
                  style: headerTextStyle,
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
      ],
    );
  }

  static pw.TextAlign _mapAlign(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return pw.TextAlign.left;
      case TextAlign.right:
      case TextAlign.end:
        return pw.TextAlign.right;
      default:
        return pw.TextAlign.center;
    }
  }
}
