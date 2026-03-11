import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'custom_input_field.dart';

class CustomSearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue, label, hint;
  final Function(String)? onChange;
  final bool enabled, allowCustomValue;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;

  const CustomSearchableDropdown({
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
    this.focusNode,
  });

  @override
  _CustomSearchableDropdownState createState() =>
      _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState extends State<CustomSearchableDropdown> {
  late TextEditingController _controller;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.selectedValue != null
          ? toParameterize(widget.selectedValue!.capitalizeFirstLetters())
          : "",
    );
  }

  @override
  void didUpdateWidget(CustomSearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _controller.text = widget.selectedValue != null
          ? toParameterize(widget.selectedValue!.capitalizeFirstLetters())
          : "";
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
          focusNode: widget.focusNode,
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
          // When the field is tapped, open the dialog
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
            List<String> dialogFilteredItems = widget.items
                .where(
                  (item) =>
                      item.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

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
                      "Available ${widget.label}",
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
                        hintText: widget.hint ?? " Search ${widget.label}...",
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
                          itemCount: dialogFilteredItems.length,
                          itemBuilder: (context, index) {
                            final item = dialogFilteredItems[index];
                            return ListTile(
                              title: Text(
                                toParameterize(item),
                                style: TextStyle(color: colorManager.bgDark),
                              ),
                              onTap: () {
                                widget.onChange?.call(item);
                                _controller.text = toParameterize(
                                  item.capitalizeFirstLetters(),
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    if (dialogFilteredItems.isEmpty)
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
