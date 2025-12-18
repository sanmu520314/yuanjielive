import 'package:flutter/material.dart';

typedef OnAppBarLeadingClickListener = void Function();
typedef OnAppBarActionIconClickListener = void Function();

AppBar buildAppBar(String title,
    {bool showAction = false,
    String? actionTitle,
    OnAppBarLeadingClickListener? leadingClickListener,
    OnAppBarActionIconClickListener? actionIconClickListener}) {
  Widget fakeActionWidget;
  if (showAction) {
    fakeActionWidget = TextButton(
      child: Text(
        actionTitle ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onPressed: () {
        actionIconClickListener?.call();
      },
    );
  } else {
    fakeActionWidget = const SizedBox();
  }
  return AppBar(
    backgroundColor: Colors.black,
    leading: IconButton(
      icon: Image.asset(
        "assets/images/ic_back.png",
        width: 28,
        height: 28,
      ),
      onPressed: () {
        leadingClickListener?.call();
      },
    ),
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(fontSize: 16),
    ),
    actions: [
      fakeActionWidget,
    ],
  );
}
