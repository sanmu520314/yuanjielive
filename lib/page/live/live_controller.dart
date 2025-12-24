import 'dart:async';

import 'package:flutter/gestures.dart';
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

  var hsitorytList = <LiveItem>[].obs;

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

  // 定义识别器
  final serviceRecognizer = TapGestureRecognizer();
  final privacyRecognizer = TapGestureRecognizer();

  final String serviceInfo = '''
  用户协议
1.接受条款
欢迎您使用我们的服务。本协议是您与我们之间关于使用我们服务的法律协议。通过访问或使用我们的服务，您确认您已阅读、理解并同意受本协议的约束。
2.服务描述
我们提供的服务允许用户进行各种操作，包括但不限于查看内容、上传内容、与其他用户互动等。
3.用户账户
为了使用我们的某些服务，您可能需要创建一个账户。您负责维护您的账户信息的保密性，并对发生在您账户下的所有活动负全部责任。
4. 用户行为
您同意不会使用我们的服务进行任何违法或未经授权的活动，包括但不限于侵犯他人知识产权、散布垃圾信息或恶意软件等。
5.内容所有权
您保留您创建并上传到我们服务的内容的所有权利。但是，通过上传内容，您授予我们非独占的、全球性的、免版税的许可，允许我们使用复制、修改、发布、展示该内容。
6.服务变更
我们保留随时修改或终止服务的权利，无论是否通知您。我们对您或任何第三方不承担任何责任。
7. 免责声明
我们的服务按"现状"和"可用"的基础提供，没有任何形式的保证，无论是明示的还是暗示的。
8.责任限制
在任何情况下，我们对因使用或无法使用我们的服务而导致的任何损失或损害不承担责任。
9.适用法律
本协议受中华人民共和国法律管辖，并按其解释。
10.协议变更
我们可能会不时地更新本协议。继续使用我们的服务表示您接受任何修改后的条款。
  ''';

  final String privacyInfo = '''
  隐私政策
1.信息收集
我们可能收集您提供给我们的个人信息，如姓名、电子邮件地址、电话号码等。我们也可能自动收集某些信息，如设备信息、IP地址、浏览器类型等。
2.信息使用
我们使用收集的信息来提供、维护和改进我们的服务，开发新的服务，以及保护我们和用户的安全。
3.信息共享
我们不会出售您的个人信息。我们可能在以下情况下共享您的信息:经您同意;与我们的服务提供商共享:遵守法律要求:保护我们的权利和财产。
4.信息安全
我们采取合理的措施来保护您的个人信息不被未经授权的访问、使用或披露。
5.您的权利
您有权访问、更正、删除您的个人信息，以及限制或反对某些处理活动。
6.儿童隐私
我们的服务不面向13岁以下的儿童。如果我们得知我们收集了13岁以下儿童的个人信息，我们将采取措施删除这些信息。
7.第三方链接
我们的服务可能包含指向第三方网站或服务的链接，这些网站或服务有自己的隐私政策。我们对这些第三方的做法不负责任。
8.政策变更
我们可能会不时地更新本隐私政策。我们会通过在我们的网站上发布新的隐私政策来通知您任何变更。
9.联系我们
如果您对本隐私政策有任何问题，请联系我们。
    ''';

  @override
  void onInit() {
    super.onInit();
    // 初始化点击事件
    serviceRecognizer.onTap = () => _showProtocolDetail("服务协议",serviceInfo);
    privacyRecognizer.onTap =
        () => _showProtocolDetail("隐私政策", privacyInfo);

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

// 在 TapGestureRecognizer 中调用此方法
  void _showProtocolDetail(String title, String content) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8, // 占屏幕 80% 高度
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E), // 保持和登录页一致的背景色
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 顶部标题和关闭按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            // 内容区域（可滚动）
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // 允许全屏高度
    );
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
                updateBroadcast(item.id!, 2);
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
            if (response.data != null &&
                response.data!.pushUrl != null &&
                response.data!.pushUrl!.isNotEmpty) {
              livePushURL.value = response.data!.pushUrl!;
              livePushId.value = response.data!.id!;
              currentState.value = 3;
            } else {
              Get.snackbar("提示", "直播历史获取失败");
            }
          } else {
            Get.snackbar("提示", response.msg ?? "发生错误");
          }
        },
        fail: (code, msg) {
          Get.snackbar("提示", msg);
        });
  }

  void updateBroadcast(int castId, int status) {
    print("updateBroadcas--------castId----------$castId");
    print("updateBroadcas--------status----------$status");
    request.updatebroadcast(
        data: {
          'id': castId,
          'status': status,
        },
        success: (response) {
          if (response.status == 0) {
          } else {}
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

    livePusher.startPushWithURL(livePushURL.value);
    updateBroadcast(livePushId.value, 1);

    _startTimer();
  }

  void startLive() async {
    // 先检查权限，通过了再继续逻辑
    bool hasPermission = await requestLivePermissions();
    if (!hasPermission) return;
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
  void goLive() {
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
    // 关键：页面销毁时释放资源
    serviceRecognizer.dispose();
    privacyRecognizer.dispose();
    super.onClose();
  }
}
