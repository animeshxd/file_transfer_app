import 'package:flutter/material.dart';

class AdaptiveOutlinedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget? label;
  final String? toolTip;

  const AdaptiveOutlinedIconButton(
      {super.key,
      required this.onPressed,
      required this.icon,
       this.label,
      this.toolTip});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return width > 300
        ? OutlinedButton.icon(onPressed: onPressed, icon: icon, label: label ?? Text(toolTip ?? ''))
        : IconButton(
            onPressed: onPressed,
            icon: icon,
            tooltip: toolTip,
          );
  }
}
