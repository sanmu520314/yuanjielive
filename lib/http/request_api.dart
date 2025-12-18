
/// @class : RequestApi
/// @name : jhf
/// @description :请求接口管理
class RequestApi{

  ///前缀地址
  static const String baseurl = 'http://39.101.73.24:8855/';
  // static const String baseurl = 'http://192.168.0.7:8855/beijing_yuanjie_live/';

  //主播登录接口
 static const String anchorlogin = 'api/live/anchorlogin.html';
  //主播获取开播日志
 static const String getbroadcastlog = 'api/live/getbroadcastlog.html';
  //主播开播推流创建开播日志
  static const String tobroadcast = 'api/live/tobroadcast.html';
  //主播修改直播记录状态
  static const String updatebroadcast = 'api/live/updatebroadcast.html';

}


