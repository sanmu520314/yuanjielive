import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/services.dart';

typedef void LivePushQueenViewCreatedCallback(id);

class LivePushQueenView extends StatefulWidget {
  const LivePushQueenView({
    Key? key,
    @required required this.onCreated,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final LivePushQueenViewCreatedCallback? onCreated;
  final x;
  final y;
  final width;
  final height;

  @override
  State<LivePushQueenView> createState() => _LivePushQueenViewState();
}

class _LivePushQueenViewState extends State<LivePushQueenView> {
  @override
  Widget build(BuildContext context) {
    return _nativeView();
  }

  _nativeView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "plugins.aliyunqueen.view",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: "plugins.aliyunqueen.view",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> _onPlatformViewCreated(id) async {
    if (widget.onCreated != null) {
      widget.onCreated!(id);
    }
  }
}
