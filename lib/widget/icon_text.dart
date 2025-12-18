import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnIconClick = void Function(bool selected);

class IconText extends StatefulWidget {
  const IconText(
      {Key? key,
      required this.text,
      required this.normalIcon,
      this.normalTextColor = const Color(0xff333333),
      this.onIconClick,
      this.selectedIcon,
      this.isSelected = false,
      this.selectedTextColor,
      this.iconWidth = 32,
      this.iconHeight = 32})
      : super(key: key);

  final String? selectedIcon;
  final String normalIcon;
  final String text;
  final Color? selectedTextColor;
  final Color normalTextColor;
  final double iconWidth;
  final double iconHeight;
  final bool isSelected;
  final OnIconClick? onIconClick;

  @override
  State<IconText> createState() => _IconTextState();
}

class _IconTextState extends State<IconText> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onIconClick != null) {
          widget.onIconClick!(widget.isSelected);
        }
        // if (mounted) {
        //   setState(() {
        //     _isSelected = !_isSelected;
        //   });
        // }
      },
      child: Column(
        children: [
          _buildIcon(),
          const SizedBox(height: 3.0),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    String iconPath = widget.normalIcon;
    if (widget.isSelected) {
      iconPath = widget.selectedIcon ?? widget.normalIcon;
    } else {
      iconPath = widget.normalIcon;
    }
    return Image.asset(iconPath,
        width: widget.iconWidth, height: widget.iconHeight);
  }

  Widget _buildText() {
    Color textColor = widget.normalTextColor;
    if (widget.isSelected) {
      textColor = widget.selectedTextColor ?? widget.normalTextColor;
    } else {
      textColor = widget.normalTextColor;
    }
    return Text(widget.text,
        style: TextStyle(color: textColor, fontSize: 10.0));
  }
}
