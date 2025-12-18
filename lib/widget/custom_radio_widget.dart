import 'package:flutter/material.dart';

class CustomRadioWidget<T> extends StatelessWidget {
  const CustomRadioWidget({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
    this.selected = false,
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? title;
  final bool selected;

  bool get checked => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    Color borderRadiusColor;
    if (checked) {
      borderRadiusColor = const Color(0xFFB2EBF2);
    } else {
      borderRadiusColor = const Color(0xFF23262F);
    }
    return GestureDetector(
      onTap: () {
        onChanged?.call(value);
      },
      child: Container(
        width: width / 2 - 30,
        height: width / 2 - 30,
        decoration: BoxDecoration(
          color: const Color(0xFF23262F),
          border: Border.all(color: borderRadiusColor, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 10,
              child: Column(
                children: [
                  Text(
                    title ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    "assets/images/ic_decorate.png",
                    width: 20,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Image.asset(
                "assets/images/ic_anchor.png",
                width: 28,
                height: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
