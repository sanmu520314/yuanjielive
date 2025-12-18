
import 'package:get/get.dart';
import 'package:yuanjielive/page/live/live_page.dart';


abstract class Routes {
  static const String splashPage = '/';

  static const String homePage = '/home';
  static const String mapPage = '/map';
  static const String cityDetailPage = '/cityDetailPage';

  ///页面合集
  static final routePage = [
    GetPage(
      name: splashPage,
      page: () =>  LivePage(),

    ),

  ];
}
