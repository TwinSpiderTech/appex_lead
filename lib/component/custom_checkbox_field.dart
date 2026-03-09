import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'custom_input_field.dart';

class CustomCheckboxField extends StatefulWidget {
  final Map<String, dynamic> items; // key: value options
  final List<String> initialSelections;
  final bool enabled;
  final ValueChanged<List<String>> onChange;
  final String label;
  final double? borderRadius;
  final FocusNode? focusNode;

  const CustomCheckboxField({
    super.key,
    required this.items,
    required this.initialSelections,
    required this.enabled,
    required this.onChange,
    required this.label,
    this.borderRadius,
    this.focusNode,
  });

  @override
  State<CustomCheckboxField> createState() => _CustomCheckboxFieldState();
}

class _CustomCheckboxFieldState extends State<CustomCheckboxField> {
  late List<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _selectedKeys = List.from(widget.initialSelections);
  }

  @override
  void didUpdateWidget(CustomCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelections != oldWidget.initialSelections) {
      _selectedKeys = List.from(widget.initialSelections);
    }
  }

  void _toggleSelection(String key) {
    if (!widget.enabled) return;
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
    widget.onChange(_selectedKeys);
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            var filteredEntries = widget.items.entries.where((entry) {
              return entry.value.toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            return Dialog(
              backgroundColor: colorManager.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Search & Add ${widget.label}",
                      style: TextStyle(
                        color: colorManager.bgDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      style: TextStyle(color: colorManager.bgDark),
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(
                          color: colorManager.bgDark.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorManager.bgDark,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: colorManager.bgDark.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorManager.bgDark),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            final isSelected = _selectedKeys.contains(
                              entry.key,
                            );
                            return ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: colorManager.bgDark,
                              ),
                              title: Text(
                                entry.value.toString(),
                                style: TextStyle(color: colorManager.bgDark),
                              ),
                              onTap: () {
                                _toggleSelection(entry.key);
                                setDialogState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    if (filteredEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No items found",
                          style: TextStyle(
                            color: colorManager.bgDark.withOpacity(0.5),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: colorManager.bgDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.enabled)
            CustomInputField(
              focusNode: widget.focusNode,
              enable: widget.enabled,
              hint: "Search & Add ${widget.label}...",
              readOnly: true,
              borderRadius: widget.borderRadius ?? 12,
              isRequired: false,
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: colorManager.textColor,
              ),
              onTap: () => _showSearchDialog(context),
            ),
          // if (widget.enabled && widget.items.isNotEmpty)

          //   const SizedBox(height: 16),
          if (widget.items.isEmpty)
            Text(
              "No options available",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              // decoration: BoxDecoration(
              //   border: Border.all(color: colorManager.secondaryColor),
              //   borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              //   color: widget.enabled
              //       ? Colors.transparent
              //       : colorManager.primaryColor.withAlpha(25),
              // ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: widget.items.entries.map((entry) {
                  final optionKey = entry.key;
                  final optionValue = entry.value.toString();
                  final isSelected = _selectedKeys.contains(optionKey);

                  return isSelected
                      ? GestureDetector(
                          onTap: () => _toggleSelection(optionKey),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorManager.primaryColor.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? colorManager.primaryColor
                                    : colorManager.secondaryColor.withOpacity(
                                        0.5,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? colorManager.primaryColor
                                      : colorManager.textColor.withOpacity(0.5),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  optionValue,
                                  style: primaryTextStyle.copyWith(
                                    color: isSelected
                                        ? colorManager.primaryColor
                                        : colorManager.textColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox();
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
