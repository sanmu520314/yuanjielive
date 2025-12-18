import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:yuanjielive/routes/routes.dart';

import 'http/request_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  Get.put(RequestRepository(), permanent: true); // 添加 permanent: true
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: Routes.routePage,
      initialRoute: Routes.splashPage,
      theme: ThemeData(
        fontFamily: 'yahei',
      ),
      navigatorKey: navigatorKey,
    ),
  );
}
