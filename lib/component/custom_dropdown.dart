import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/custom_toast_messages.dart';
import 'package:appex_lead/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hugeicons/hugeicons.dart';

// ignore: must_be_immutable
class CustomDropdown extends StatefulWidget {
  final double? width, maxWidth, textSize, borderRadius;
  final List<String> items;
  String? selectedValue, label;
  final Function(String)? onChange;
  final Function()? onInit;
  final IconData? prefixIcon;
  final EdgeInsetsGeometry? padding;
  CustomDropdown({
    super.key,
    required this.items,
    this.onChange,
    this.selectedValue,
    this.onInit,
    this.width,
    this.maxWidth,
    this.textSize,
    this.prefixIcon,
    this.label = 'item',
    this.padding,
    this.borderRadius,
  });
  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      widget.onInit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        if (widget.items.isEmpty) {
          showToast(message: "No ${widget.label?.toLowerCase()} available");
        } else {
          _showCustomMenu(context, widget.items, widget.onChange);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        width: double.infinity,
        padding:
            widget.padding ??
            const EdgeInsets.only(left: 10, right: 10, top: 12, bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colorManager.borderColor, width: 1),
          // color: Colors.red,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
        ),
        child: Row(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.prefixIcon != null)
              Icon(widget.prefixIcon!, color: colorManager.secondaryColor),
            Expanded(
              child: Container(
                // constraints: BoxConstraints(maxWidth: width * 0.2),
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth ?? width * 0.6,
                ),
                child: Text(
                  // "asjbdalksd bsaojhdplaksndpk",
                  widget.selectedValue != null &&
                          widget.selectedValue!.isNotEmpty
                      ? toParameterize(
                          widget.selectedValue!.capitalizeFirstLetters(),
                        )
                      : 'Select ${widget.label}',
                  // toParameterize(widget.selectedValue ?? 'Select an item'),
                  style: TextStyle(
                    color: colorManager.textColor,
                    fontSize: widget.textSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: colorManager.textColor,
              // color: colorManager.whiteColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomMenu(
    BuildContext context,
    List<String> items,
    Function? onChange,
  ) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    double width = widget.width ?? renderBox.size.width;

    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final selectedValue = await showMenu<String>(
      color: colorManager.primaryColor,
      context: context,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height * 1.1,
        offset.dx + renderBox.size.width,
        0,
      ),
      items: items.map((String item) {
        return PopupMenuItem<String>(
          value: item,
          child: Container(
            constraints: BoxConstraints(minWidth: width, maxWidth: width),
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            // decoration: BoxDecoration(color: colorManager.primaryColor),
            child: Text(
              toParameterize(item),
              style: TextStyle(color: colorManager.bgDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );

    if (selectedValue != null) {
      setState(() {
        widget.selectedValue = selectedValue;
        // print(_selectedValue);
        onChange!(widget.selectedValue);
      });
    }
  }
}

class CustomDropdown2 extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String? placeholderText;
  final String keyToPreview;
  final double? textSize, borderRadius;
  final bool disabled;
  double? width;
  final Map<String, dynamic>? selectedValue;
  final Function(Map<String, dynamic>)? onChange;

  CustomDropdown2({
    super.key,
    required this.items,
    this.onChange,
    this.textSize,
    this.placeholderText,
    this.selectedValue,
    this.width,
    this.disabled = false,
    required this.keyToPreview,
    this.borderRadius,
  });

  @override
  _CustomDropdown2State createState() => _CustomDropdown2State();
}

class _CustomDropdown2State extends State<CustomDropdown2> {
  late Map<String, dynamic> _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue ?? {};
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        if (widget.disabled) {
          return;
        }
        if (widget.items.isEmpty) {
          showToast(
            message: "No ${widget.placeholderText?.toLowerCase()} available",
          );
        } else {
          _showCustomMenu(context, widget.items, widget.onChange);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.disabled
                ? colorManager.borderColor
                : colorManager.borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: widget.width ?? 120),
              child: Text(
                _selectedValue.isNotEmpty
                    ? _selectedValue[widget.keyToPreview] ??
                          'Select ${widget.placeholderText ?? "item"}'
                    : 'Select ${widget.placeholderText ?? "item"}',
                style: TextStyle(
                  fontSize: widget.textSize,
                  color: colorManager.textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorManager.textColor),
          ],
        ),
      ),
    );
  }

  void _showCustomMenu(
    BuildContext context,
    List<Map<String, dynamic>> items,
    Function(Map<String, dynamic>)? onChange,
  ) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    double width = widget.width ?? renderBox.size.width;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final selectedValue = await showMenu<Map<String, dynamic>>(
      color: colorManager.primaryColor,
      context: context,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height * 1.1,
        offset.dx + renderBox.size.width,
        0,
      ),
      items: items.map((Map<String, dynamic> item) {
        return PopupMenuItem<Map<String, dynamic>>(
          value: item, // Passing the entire document snapshot
          child: Container(
            width: widget.width ?? width,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(
              item[widget.keyToPreview] ??
                  "", // Replace 'category_name' with the actual field
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorManager.bgDark),
            ),
          ),
        );
      }).toList(),
    );

    if (selectedValue != null) {
      setState(() {
        _selectedValue = selectedValue;
        if (onChange != null) {
          onChange(selectedValue);
        }
      });
    }
  }
}
