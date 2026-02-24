import 'package:flutter/material.dart';
import 'package:appex_lead/main.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Icon inactiveIcon, activeIcon;

  CustomSwitch({
    required this.value,
    required this.onChanged,
    required this.inactiveIcon,
    required this.activeIcon,
    this.width = 60.0,
    this.height = 30.0,
  });

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(width: 1, color: colorManager.primaryColor),
          color: colorManager.primaryColor,
          // color: widget.value ? primary : bgLColor,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              top: 0,
              bottom: 0,
              left: widget.value ? widget.width - widget.height : 0.0,
              right: widget.value ? 0.0 : widget.width - widget.height,
              child: Container(
                width: widget.height,
                height: widget.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.value ? Colors.white : Colors.grey.shade200,
                ),
                child: Center(
                  child: widget.value ? widget.inactiveIcon : widget.activeIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
