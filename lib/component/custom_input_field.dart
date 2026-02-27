// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:appex_lead/main.dart';

class CustomInputField extends StatefulWidget {
  final String? label, hint, initialValue;
  final bool enable;
  final FocusNode? focusNode;
  final Widget? suffixIcon, prefixIcon;
  final TextInputType type;
  final bool readOnly;
  final bool isRequired;
  final bool obsecure;
  final bool autoFocus;
  final int? maxLength;
  final int? minLength;
  final double fontSize, borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final Function? onFieldSubmitted;

  final Function(String)? onChanged;
  final VoidCallback? onTap;

  final TextEditingController? controller;

  final int maxLine;
  const CustomInputField({
    super.key,
    this.maxLine = 1,
    this.fontSize = 12,
    this.enable = true,
    this.controller,
    this.obsecure = false,
    this.isRequired = true,
    this.focusNode,
    this.readOnly = false,
    this.type = TextInputType.text,
    this.hint,
    this.suffixIcon,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.contentPadding = const EdgeInsets.only(
      left: 18,
      top: 10,
      bottom: 10,
      right: 18,
    ),
    this.borderRadius = 12,
    this.initialValue,
    this.label,
    this.autoFocus = false,
    this.onTap,
    this.maxLength,
    this.minLength,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  @override
  void initState() {
    super.initState();
    // if (widget.controller != null && widget.hint != null) {
    //   widget.controller!.text = widget.hint!;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        // onTap: () {
        //   widget.onTap;
        // },
        child: TextFormField(
          maxLength: widget.maxLength,

          autofocus: widget.autoFocus,
          onFieldSubmitted: (_) {
            widget.onFieldSubmitted != null ? widget.onFieldSubmitted!() : null;
          },
          initialValue: widget.initialValue,
          style: TextStyle(
            color: colorManager.textColor,
            fontSize: widget.fontSize,
          ),
          obscureText: widget.obsecure,
          readOnly: widget.readOnly,
          focusNode: widget.focusNode,
          keyboardType: widget.type,
          enabled: widget.enable,
          onChanged: (value) {
            widget.onChanged != null ? widget.onChanged!(value) : null;
          },
          onTap: widget.onTap,
          validator: widget.isRequired
              ? (value) {
                  return value == null || value.isEmpty
                      ? "Field can't be empty!"
                      : null;
                }
              : widget.minLength != null
              ? (value) {
                  return value!.length < widget.minLength!
                      ? "Field must be at least ${widget.minLength} characters!"
                      : null;
                }
              : null,

          controller: widget.controller,
          cursorColor: colorManager.secondaryColor,
          maxLines: widget.maxLine,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            labelText: widget.label,
            suffixIcon: widget.suffixIcon,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w300,
              height: 0.7,
              fontSize: widget.fontSize,
            ),
            floatingLabelStyle: TextStyle(
              fontFamily: 'SF Pro',
              color: colorManager.secondaryColor,
              height: 0.8,
              fontSize: 12,
            ),
            contentPadding: widget.contentPadding,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorManager.secondaryColor),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorManager.secondaryColor),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorManager.borderColor),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: colorManager.secondaryColor),
            ),
            // label: Text("data"),
            labelStyle: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: widget.fontSize,
              color: colorManager.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInput2 extends StatelessWidget {
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChange;
  final VoidCallback? onTap;
  final FocusNode focusNode;
  final TextEditingController? controller;
  final double fontSize, borderRadius, height;
  final EdgeInsetsGeometry contentPadding;
  final bool enabled;
  final String hint;
  const CustomInput2({
    super.key,
    this.onFieldSubmitted,
    this.onChange,
    this.controller,
    required this.focusNode,
    required this.hint,
    this.fontSize = 12,
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 4,
    ),
    this.height = 40,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        enabled: enabled,
        style: TextStyle(color: colorManager.textColor),
        onTap: onTap,
        controller: controller,
        onChanged: onChange,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorManager.textColor,
            fontWeight: FontWeight.w300,
            height: 0.7,
            fontSize: fontSize,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'SF Pro',
            color: colorManager.primaryColor,
            height: 0.8,
            fontSize: 12,
          ),
          contentPadding: contentPadding,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorManager.primaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorManager.primaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorManager.primaryColor),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: colorManager.primaryColor),
          ),
          // label: Text("data"),
          labelStyle: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: fontSize,
            color: colorManager.primaryColor,
          ),
        ),
      ),
    );
  }
}
