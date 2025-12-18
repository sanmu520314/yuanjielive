import 'package:get/get.dart';

/// @class : StringStyles
/// @name : jhf
/// @description :字符管理
class StringStyles{

  static const String appName = 'appName';
  static const String loading = 'loading';

  static const String comtitle = 'comtitle';
  static const String system_settings = 'system_settings';

  static const String settingLanguageDefault = "settingLanguageDefault";

  static const String collectTitle = "collectTitle";

  static const String enter = "enter";
  static const String quit = "quit";


}

///使用Get配置语言环境
///使用Get.updateLocale(locale);即可更新
class Messages extends Translations{
  @override
  Map<String, Map<String, String>> get keys =>{
    'zh_CN' :{
      StringStyles.appName : '智慧党建综合信息平台',
      StringStyles.loading : '加载中...',

      StringStyles.collectTitle : "我的收藏",
      StringStyles.enter : "确认",
      StringStyles.quit : "取消",
      StringStyles.comtitle : "智慧党建综合信息平台",
      StringStyles.system_settings : "系统设置",

    },
    'en_US' : {
      StringStyles.appName : 'BlogTime',
      StringStyles.loading : 'Loading...',

      StringStyles.settingLanguageDefault : "Follow System",

      StringStyles.collectTitle : "My collection",
      StringStyles.enter : "Confirm",
      StringStyles.quit : "Quit",
      StringStyles.comtitle : "Smart Party Building Comprehensive Information Platform",
      StringStyles.system_settings : "System Settings",
    }
  };

}

