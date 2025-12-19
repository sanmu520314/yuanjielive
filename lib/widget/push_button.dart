import 'package:flutter/material.dart';

typedef PushButtonActionCallback = void Function();

class PushButton extends StatefulWidget {
  final String title;
  final double? width;
  final double? height;
  final bool enable;
  final Color color;
  final double titleSize;
  final PushButtonActionCallback? action;

  const PushButton(
      {Key? key,
      required this.title,
      this.width,
      this.height,
      this.action,
      this.titleSize = 18,
      this.color = Colors.blue,
      this.enable = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    if (widget.enable) {
      buttonColor = widget.color;
    } else {
      buttonColor = const Color(0x4D4DCFE1);
    }
    Size minimumSize = Size(widget.width ?? 0, widget.height ?? 0);
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        minimumSize: WidgetStateProperty.all(minimumSize),
      ),
      onPressed: (() {
        if (widget.enable) {
          widget.action?.call();
        }
      }),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: widget.titleSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
