// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:appex_lead/main.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  final String label;
  bool isLoading;
  final double labelSize, borderRadius;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  Color? backgroundColor, textColr, boderColor;
  bool disabled;
  CustomButton({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColr,
    this.isLoading = false,
    this.boderColor = Colors.transparent,
    required this.onTap,
    this.labelSize = 16,
    this.borderRadius = 30,
    this.padding = const EdgeInsets.all(14),
    this.disabled = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true), // Trigger hover effect
      onExit: (_) => setState(() => _isHovered = false), // Reset hover effect
      child: InkWell(
        onTap: widget.isLoading || widget.disabled
            ? () {
                print("Disabled");
              }
            : widget.onTap,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: widget.boderColor ?? Colors.transparent),
            color: widget.disabled
                ? Colors.grey
                : widget.backgroundColor ?? colorManager.primaryColor,
          ),
          child: Center(
            child:
                //  widget.isLoading
                // ? Text(
                //     "Loading...",
                //     style: TextStyle(
                //       color: widget.textColr ?? colorManager.bgDark,
                //       fontSize: widget.labelSize,
                //     ),
                //   )
                // ? CircularProgressIndicator(color: colorManager.whiteColor, )
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColr ?? colorManager.bgDark,
                    fontSize: widget.labelSize,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
