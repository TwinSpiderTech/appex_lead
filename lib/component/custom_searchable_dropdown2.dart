import 'package:appex_lead/main.dart';
import 'package:flutter/material.dart';
import 'custom_input_field.dart';

class CustomSearchableDropdown2 extends StatefulWidget {
  final Map<String, dynamic> items;
  final String? selectedValue, label, hint;
  final Function(String)? onChange;
  final bool enabled, allowCustomValue;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomSearchableDropdown2({
    super.key,
    required this.items,
    this.onChange,
    this.selectedValue,
    this.label,
    this.hint,
    this.padding,
    this.enabled = true,
    this.allowCustomValue = true,
    this.borderRadius = 12,
  });

  @override
  _CustomSearchableDropdown2State createState() =>
      _CustomSearchableDropdown2State();
}

class _CustomSearchableDropdown2State extends State<CustomSearchableDropdown2> {
  late TextEditingController _controller;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    // selectedValue is the KEY, we show the VALUE
    String initialDisplay = "";
    if (widget.selectedValue != null) {
      if (widget.items.containsKey(widget.selectedValue)) {
        initialDisplay = widget.items[widget.selectedValue]?.toString() ?? "";
      } else if (widget.allowCustomValue) {
        initialDisplay = widget.selectedValue!;
      }
    }
    _controller = TextEditingController(text: initialDisplay);
  }

  @override
  void didUpdateWidget(CustomSearchableDropdown2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue ||
        widget.items != oldWidget.items) {
      String display = "";
      if (widget.selectedValue != null) {
        if (widget.items.containsKey(widget.selectedValue)) {
          display = widget.items[widget.selectedValue]?.toString() ?? "";
        } else if (widget.allowCustomValue) {
          display = widget.selectedValue!;
        }
      }
      _controller.text = display;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          controller: _controller,
          enable: widget.enabled,
          hint: widget.hint ?? "Search ${widget.label}...",
          readOnly: false, // Allow typing to search
          borderRadius: widget.borderRadius ?? 12,
          isRequired: false,
          suffixIcon: Icon(
            _isMenuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: colorManager.textColor,
          ),
          onChanged: (val) {
            if (widget.enabled && !_isMenuOpen) {
              setState(() => _isMenuOpen = true);
              _showSearchDialog(context);
            }
          },
          onTap: widget.enabled
              ? () {
                  _showSearchDialog(context);
                }
              : null,
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Filter keys based on their values containing the search query
            List<String> filteredKeys = widget.items.keys.where((key) {
              String value = widget.items[key]?.toString() ?? "";
              return value.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  key.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              backgroundColor: colorManager.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select ${widget.label}",
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
                          itemCount: filteredKeys.length,
                          itemBuilder: (context, index) {
                            final key = filteredKeys[index];
                            final value = widget.items[key]?.toString() ?? "";
                            return ListTile(
                              title: Text(
                                value,
                                style: TextStyle(color: colorManager.bgDark),
                              ),
                              // subtitle: Text(
                              //   key,
                              //   style: TextStyle(
                              //     color: colorManager.bgDark.withOpacity(0.5),
                              //     fontSize: 12,
                              //   ),
                              // ),
                              onTap: () {
                                widget.onChange?.call(key);
                                _controller.text = value;
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    if (filteredKeys.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text(
                              "No items found",
                              style: TextStyle(
                                color: colorManager.bgDark.withOpacity(0.5),
                              ),
                            ),
                            if (widget.allowCustomValue &&
                                searchQuery.trim().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorManager.bgDark,
                                  foregroundColor: colorManager.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      widget.borderRadius ?? 12,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  widget.onChange?.call(searchQuery.trim());
                                  _controller.text = searchQuery.trim();

                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.add),
                                label: Text("Add \"$searchQuery\""),
                              ),
                            ],
                          ],
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
}
