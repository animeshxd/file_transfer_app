import 'package:flutter/material.dart';

class YesNoButton extends StatefulWidget {
  final Future<void> Function(bool) onChanged;
  final bool value;
  const YesNoButton({Key? key, required this.onChanged, required this.value})
      : super(key: key);

  @override
  State<YesNoButton> createState() => _YesNoButtonState();
}

class _YesNoButtonState extends State<YesNoButton> {
  bool value = false;
  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          value = !value;
          widget.onChanged(value);
        });
      },
      child: Text(
        !value ? "Yes" : "No",
      ),
    );
  }
}
