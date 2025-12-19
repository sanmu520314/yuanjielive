import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/base/live_base.dart';
import 'package:flutter_livepush_plugin/base/live_base_def.dart';
import 'package:flutter_livepush_plugin/pusher/live_push_config.dart';
import 'package:flutter_livepush_plugin/pusher/live_push_def.dart';
import 'package:flutter_livepush_plugin/pusher/live_pusher.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yuanjielive/http/request_repository.dart';
import 'package:yuanjielive/model/live_history_model.dart';

class LiveController extends GetxController {
  // 模拟当前状态：0-登录, 1-历史记录, 2-准备开播, 3-直播中, 4-直播结束
  var currentState = 0.obs;

// 1. 定义 TextEditingController
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  final deviceCodeController = TextEditingController();

  // 登录表单
  var account = ''.obs;
  var password = ''.obs;
  var anchorId = 0.obs;
  var isAgreed = false.obs;

  var isPushing = false.obs; //是否推流直播中

  var  hsitorytList  = <LiveItem>[].obs;


  var livePushURL = "".obs;
  var livePushId = 0.obs;

  // 模拟你的 pushMode 状态，0 为基础模式，1 为推流模式
  var livePushMode = 0.obs;

  late AlivcLivePusher livePusher;
  late AlivcLivePushConfig pusherConfig;

  late RequestRepository request;


  // 1. 计时相关变量
  Timer? _timer;
  var secondsElapsed = 0.obs; // 累计秒数
  var liveDuration = "00:00:00".obs; // 用于 UI 显示的时长字符串

  // 2. 格式化时间方法
  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // 3. 开始计时
  void _startTimer() {
    _timer?.cancel(); // 先取消旧的
    secondsElapsed.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsElapsed.value++;
      liveDuration.value = _formatDuration(secondsElapsed.value);
    });
  }

  // 4. 停止计时
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }


  void onPreviewCreated(dynamic viewId) async {
    print("Camera preview created for ViewID: $viewId");

    // 增加延时，确保 Native 视图容器已经完全挂载
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // 启动预览前，先检查状态 (SDK 如果有 getState 最好判断一下)
      // 强制先 stop 一次可以增加成功率
      await livePusher.stopPreview();
      await livePusher.startPreview();
      print("startPreview Success");
    } catch (e) {
      print("startPreview Error: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();

    request = Get.find<RequestRepository>();

    // 监听 currentState 变化
    ever(currentState, (int state) {
      // 只要状态改变（比如从登录跳到历史，或者从直播跳到结束）
      // 就重置输入框和协议勾选状态
      _resetInputs();

      // 逻辑补充：如果状态切回到历史记录页面，刷新一次历史列表
      if (state == 1) {
        getLiveHistory();
      }
    });

    initSDK();
    initlivePusher();
    initPush();
  }


  void _resetInputs() {
    accountController.clear();
    passwordController.clear();
    deviceCodeController.clear();
    isAgreed.value = false;
    // 如果需要清空推流地址等也可以在这里做
  }

  void login() {
    // 2. 登录时直接获取 text 属性
    String account = accountController.text.trim();
    String password = passwordController.text.trim();

    if (account.isEmpty || password.isEmpty) {
      Get.snackbar("提示", "请输入账号密码");
      return;
    }
    if (!isAgreed.value) {
      Get.snackbar("提示", "请先阅读并同意服务协议");
      return;
    }
    print("正在登录：账号-$account, 密码-$password");
    request.anchorlogin(
        data: {
          'accountName': account,
          'accountPassword': password,
        },
        success: (response) {
          if (response.status == 0) {
            Get.snackbar("提示", "登录成功");
            currentState.value = 1;
            anchorId.value = response.data.id;
          } else {
            Get.snackbar("提示", "登录失败");
          }
        },
        fail: (code, msg) {
          Get.snackbar("提示", msg);
        });
  }

  void getLiveHistory() {
    print("getLiveHistory----------anchorId--------${anchorId.value}");
    request.getbroadcastlog(
        data: {
          'anchorId': anchorId.value,
        },
        success: (response) {
          if (response.status == 0) {
            // 1. 赋值数据
            List<LiveItem> dataList = response.data ?? [];
            hsitorytList.value = dataList;
            // 2. 遍历判断并调用方法
            for (var item in dataList) {
              if (item.status != 2) {
                // 假设 updateBroadcas 需要传入 id 或者 item 对象
                updateBroadcast(item.id!,2);
              }
            }
          } else {
            Get.snackbar("提示", "直播历史获取失败");
          }
        },
        fail: (code, msg) {});
  }
  void GenerateLivePushURL(String deviceCode) {
    print("GenerateLivePushURL--------anchorId----------${anchorId.value}");
    print("GenerateLivePushURL--------deviceCode----------$deviceCode");
    request.tobroadcast(
        data: {
          'anchorId': anchorId.value,
          'deviceCode': deviceCode,
        },
        success: (response) {
          if (response.status == 0) {
            // livePushURL.value = response.data?.pushUrl ?? "";
            if (response.data != null && response.data!.pushUrl != null && response.data!.pushUrl!.isNotEmpty) {
              livePushURL.value = response.data!.pushUrl!;
              livePushId.value = response.data!.id!;
              currentState.value = 3;
            } else {
              Get.snackbar("提示", "直播历史获取失败");
            }
          } else {
            Get.snackbar("提示",response.msg?? "发生错误");
          }
        },
        fail: (code, msg) {
          Get.snackbar("提示",msg);
        });

  }


  void updateBroadcast(int castId,int  status) {
    print("updateBroadcas--------castId----------$castId");
    print("updateBroadcas--------status----------$status");
    request.updatebroadcast(
        data: {
          'id': castId,
          'status': status,
        },
        success: (response) {
          if (response.status == 0) {

          } else {

          }
        },
        fail: (code, msg) {});
  }

  void initSDK() {
    AlivcLiveBase.registerSDK();
    AlivcLiveBase.setListener(AlivcLiveBaseListener(
      onLicenceCheck: (AlivcLiveLicenseCheckResultCode result, String reason) {
        printInfo(info: "result: $result, reason: $reason");
        if (result == AlivcLiveLicenseCheckResultCode.success) {
          /// 注册SDK成功
        }
      },
    ));
  }

  void initlivePusher() {
    /// 创建AlivcLivePusher实例
    livePusher = AlivcLivePusher.init();

    /// 创建Config，将AlivcLivePusherConfig同AlivcLivePusher联系起来
    livePusher.createConfig();

    /// 创建AlivcLivePusherConfig实例

    /// AlivcLivePushConfig   AlivcLivePushConfig
    pusherConfig = AlivcLivePushConfig.init();

    /// 设置推流参数
    /// 设置分辨率为540P
    pusherConfig.setResolution(AlivcLivePushResolution.resolution_540P);

    /// 设置视频采集帧率为20fps。建议用户使用20fps
    pusherConfig.setFps(AlivcLivePushFPS.fps_20);

    /// 打开码率自适应，默认为true
    pusherConfig.setEnableAutoBitrate(true);

    /// 设置关键帧间隔。关键帧间隔越大，延时越高。建议设置为1-2
    pusherConfig.setVideoEncodeGop(AlivcLivePushVideoEncodeGOP.gop_2);

    /// 设置重连时长为2s。单位为毫秒，设置不小于1秒，建议使用默认值即可。
    pusherConfig.setConnectRetryInterval(2000);

    /// 设置预览镜像为关闭
    pusherConfig.setPreviewMirror(false);

    /// 设置推流方向为竖屏
    pusherConfig.setOrientation(AlivcLivePushOrientation.portrait);
  }

  void initPush() {
    livePusher.initLivePusher();

    /// 设置推流状态监听回调
    livePusher.setInfoDelegate();

    /// 设置推流错误监听回调
    livePusher.setErrorDelegate();

    /// 设置推流网络监听回调
    livePusher.setNetworkDelegate();

    /// 推流错误监听回调
    /// SDK错误回调
    livePusher.setOnSDKError((errorCode, errorDescription) {
      printInfo(
          info:
              "setOnSDKError    ------  errorCode: $errorCode, errorDescription: $errorDescription");
    });

    /// 系统错误回调
    livePusher.setOnSystemError((errorCode, errorDescription) {
      printInfo(
          info:
              "setOnSystemError    ------  errorCode: $errorCode, errorDescription: $errorDescription");
    });

    /// 推流状态监听回调
    /// 开始预览回调
    livePusher.setOnPreviewStarted(() {
      printInfo(info: "setOnPreviewStarted    ------ ");
    });

    /// 停止预览回调
    livePusher.setOnPreviewStoped(() {
      printInfo(info: "setOnPreviewStoped    ------ ");
    });

    /// 渲染第一帧回调
    livePusher.setOnFirstFramePreviewed(() {
      printInfo(info: "setOnFirstFramePreviewed    ------ ");
    });

    /// 推流开始回调
    livePusher.setOnPushStarted(() {
      printInfo(info: "setOnPushStarted    ------ ");
      isPushing.value = true;
    });

    /// 摄像头推流暂停回调
    livePusher.setOnPushPaused(() {
      printInfo(info: "setOnPushPaused    ------ ");
    });

    /// 摄像头推流恢复回调
    livePusher.setOnPushResumed(() {
      printInfo(info: "setOnPushResumed    ------ ");
    });

    /// 重新推流回调
    livePusher.setOnPushRestart(() {
      printInfo(info: "setOnPushRestart    ------ ");
      isPushing.value = true;
    });

    /// 推流停止回调
    livePusher.setOnPushStoped(() {
      printInfo(info: "setOnPushStoped    ------ ");
      isPushing.value = false;
    });

    /// 推流网络监听回调
    /// 推流链接失败
    livePusher.setOnConnectFail((errorCode, errorDescription) {
      printInfo(
          info:
              "setOnConnectFail    ------  errorCode: $errorCode, errorDescription: $errorDescription");
      isPushing.value = false;
    });

    /// 网络恢复
    livePusher.setOnConnectRecovery(() {
      printInfo(info: "setOnConnectRecovery    ------ ");
    });

    /// 连接被断开
    livePusher.setOnConnectionLost(() {
      printInfo(info: "setOnConnectionLost    ------ ");
      isPushing.value = false;
    });

    /// 网络差回调
    livePusher.setOnNetworkPoor(() {
      printInfo(info: "setOnNetworkPoor    ------ ");
    });

    /// 重连失败回调
    livePusher.setOnReconnectError((errorCode, errorDescription) {
      printInfo(
          info:
              "setOnReconnectError    ------  errorCode: $errorCode, errorDescription: $errorDescription");
    });

    /// 重连开始回调
    livePusher.setOnReconnectStart(() {
      printInfo(info: "setOnReconnectStart    ------ ");
    });

    /// 重连成功回调
    livePusher.setOnReconnectSuccess(() {
      printInfo(info: "setOnReconnectSuccess    ------ ");
    });
  }


  void reverseCamera() {
    livePusher.switchCamera();
  }
  void stopPushing() {
    // 1. 停止推流
    livePusher.stopPush();
    // 2. 停止预览
    livePusher.stopPreview();
    // 3. 释放旧的销毁回调 (可选，防止内存泄漏)
    // 4. 重置 UI 状态
    livePushMode.value = 0;
    currentState.value = 4;
    isPushing.value = false;
    // 关键：如果第二次进入依然没画面，建议在此时直接销毁实例，下次进入重新 init
    // livePusher.destroy();
  }



  void startPush() {
    isPushing.value = true;
    print("startPush--------livePushURL----------${livePushURL.value}");
    print("startPush-------- livePushId----------${livePushId.value}");

    livePusher.startPushWithURL( livePushURL.value);
    updateBroadcast(livePushId.value, 1);

    _startTimer();
  }

  void startLive() {
    currentState.value = 2;
  }
// 请求权限的方法
  Future<bool> requestLivePermissions() async {
    // 1. 待申请的权限列表
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    // 2. 检查权限状态
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted) {
      print("权限获取成功");
      return true;
    } else {
      // 3. 如果用户拒绝了权限
      Get.snackbar(
        "权限提醒",
        "直播需要摄像头和麦克风权限，请在设置中开启",
        mainButton: TextButton(
          onPressed: () => openAppSettings(), // 引导用户去系统设置页
          child: const Text("去设置"),
        ),
      );
      return false;
    }
  }
  //进入直播
  void goLive() async{
    // 先检查权限，通过了再继续逻辑
    bool hasPermission = await requestLivePermissions();
    if (!hasPermission) return;
    String deviceCode = deviceCodeController.text.trim();
    GenerateLivePushURL(deviceCode);
  }

  void endLive() {
    stopPushing();
    updateBroadcast(livePushId.value, 2);
    _stopTimer();
  }

  void backToHistory() {
    currentState.value = 1;
  }

  @override
  void onClose() {
    // 记得销毁控制器释放内存
    accountController.dispose();
    passwordController.dispose();
    deviceCodeController.dispose();
    _stopTimer();
    super.onClose();
  }
}
