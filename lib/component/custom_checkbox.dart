import 'package:flutter/material.dart';
import 'package:appex_lead/main.dart';
import 'package:appex_lead/utils/helpers.dart';

class CustomCheckbox extends StatelessWidget {
  bool initialValue;
  var color, labelColor;
  var labelSize, req;
  double spacing;
  String text;
  Function onChange;
  CustomCheckbox({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.color,
    required this.req,
    this.spacing = 0,
    required this.labelColor,
    this.labelSize = 12,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          activeColor: Color(int.parse(hexToColor(color))),
          value: initialValue,
          onChanged: (newValue) {
            onChange(newValue);
          },
        ),
        SizedBox(width: spacing),
        Text(
          text,
          style: TextStyle(
            fontSize: labelSize.toDouble(),
            color: Color(int.parse(hexToColor(labelColor))),
          ),
        ),
        SizedBox(width: 4),
        req
            ? Icon(Icons.star, color: colorManager.primaryColor, size: 8)
            : SizedBox(),
      ],
    );
  }
}
