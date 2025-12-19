import 'dart:convert';
import 'package:yuanjielive/http/request.dart';
import 'package:yuanjielive/http/request_api.dart';
import 'package:yuanjielive/model/live_history_model.dart';
import 'package:yuanjielive/model/login_model.dart';
import 'package:yuanjielive/model/to_broadcast_model.dart';
import 'package:yuanjielive/model/update_broadcast_model.dart';



typedef SuccessOver<T> = Function(T data, bool over);

class RequestRepository {

  //主播登录接口
  void anchorlogin({
    required Map<String, dynamic> data,
    required Function(LoginResponse) success,
    required Function(int, String) fail,
  }) {
    // 打印请求参数
    print('anchorlogin 请求参数: $data');
    print('anchorlogin API: ${RequestApi.anchorlogin}');

    Request.postForm<String>(
      RequestApi.anchorlogin,
      data,
      dialog: false,
      skipResultWrap: true,
      success: (jsonString) {
        print('anchorlogin 原始响应: "$jsonString"');

        if (jsonString.isEmpty) {
          fail(-1, '服务器返回空数据');
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          print('anchorlogin 解析后数据: $data');

          if (data['status'] == 0) {

            final response = LoginResponse.fromJson(data);
            success(response);
          } else {
            print('anchorlogin 服务器返回错误: ${data['status']} - ${data['msg']}');
            fail(data['status'] ?? -1, data['msg'] ?? '未知错误');

          }
        } catch (e) {
          print('anchorlogin JSON解析异常: $e');
          fail(-1, '数据解析失败: $e');

        }
      },
      fail: (code, msg) {
        print('anchorlogin 网络请求失败: $code - $msg');
        fail(code, msg);
      },
    );
  }



  void getbroadcastlog({
    required Map<String, dynamic> data,
    required Function(LiveHistoryResponse) success,
    required Function(int, String) fail,
  }) {
    // 打印请求参数
    print('getbroadcastlog 请求参数: $data');
    print('getbroadcastlog API: ${RequestApi.getbroadcastlog}');

    Request.postForm<String>(
      RequestApi.getbroadcastlog,
      data,
      dialog: false,
      skipResultWrap: true,
      success: (jsonString) {
        print('getbroadcastlog 原始响应: "$jsonString"');

        if (jsonString.isEmpty) {
          fail(-1, '服务器返回空数据');
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          print('getbroadcastlog 解析后数据: $data');

          if (data['status'] == 0) {

            final response = LiveHistoryResponse.fromJson(data);
            success(response);
          } else {
            print('getbroadcastlog 服务器返回错误: ${data['status']} - ${data['msg']}');
            fail(data['status'] ?? -1, data['msg'] ?? '未知错误');

          }
        } catch (e) {
          print('getbroadcastlog JSON解析异常: $e');
          fail(-1, '数据解析失败: $e');

        }
      },
      fail: (code, msg) {
        print('getbroadcastlog 网络请求失败: $code - $msg');
        fail(code, msg);
      },
    );
  }



  void tobroadcast({
    required Map<String, dynamic> data,
    required Function(ToBroadcastResponse) success,
    required Function(int, String) fail,
  }) {
    // 打印请求参数
    print('tobroadcast 请求参数: $data');
    print('tobroadcast API: ${RequestApi.tobroadcast}');

    Request.postForm<String>(
      RequestApi.tobroadcast,
      data,
      dialog: false,
      skipResultWrap: true,
      success: (jsonString) {
        print('tobroadcast 原始响应: "$jsonString"');

        if (jsonString.isEmpty) {
          fail(-1, '服务器返回空数据');
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          print('tobroadcast 解析后数据: $data');

          if (data['status'] == 0) {

            final response = ToBroadcastResponse.fromJson(data);
            success(response);
          } else {
            print('tobroadcast 服务器返回错误: ${data['status']} - ${data['msg']}');
            fail(data['status'] ?? -1, data['msg'] ?? '未知错误');

          }
        } catch (e) {
          print('tobroadcast JSON解析异常: $e');
          fail(-1, '数据解析失败: $e');

        }
      },
      fail: (code, msg) {
        print('tobroadcast 网络请求失败: $code - $msg');
        fail(code, msg);
      },
    );
  }



  void updatebroadcast({
    required Map<String, dynamic> data,
    required Function(UpdateBroadcastResponse) success,
    required Function(int, String) fail,
  }) {
    // 打印请求参数
    print('updatebroadcast 请求参数: $data');
    print('updatebroadcast API: ${RequestApi.updatebroadcast}');

    Request.postForm<String>(
      RequestApi.updatebroadcast,
      data,
      dialog: false,
      skipResultWrap: true,
      success: (jsonString) {
        print('updatebroadcast 原始响应: "$jsonString"');

        if (jsonString.isEmpty) {
          fail(-1, '服务器返回空数据');
          return;
        }

        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          print('updatebroadcast 解析后数据: $data');

          if (data['status'] == 0) {

            final response = UpdateBroadcastResponse.fromJson(data);
            success(response);
          } else {
            print('updatebroadcast 服务器返回错误: ${data['status']} - ${data['msg']}');
            fail(data['status'] ?? -1, data['msg'] ?? '未知错误');

          }
        } catch (e) {
          print('updatebroadcast JSON解析异常: $e');
          fail(-1, '数据解析失败: $e');

        }
      },
      fail: (code, msg) {
        print('updatebroadcast 网络请求失败: $code - $msg');
        fail(code, msg);
      },
    );
  }

}
