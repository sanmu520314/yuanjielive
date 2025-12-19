import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/pusher/live_pusher_preview.dart';
import 'package:get/get.dart';
import 'package:yuanjielive/model/live_history_model.dart';
import 'package:yuanjielive/widget/dashed_line_painter.dart';

import 'live_controller.dart';

class LivePage extends StatelessWidget {
  final LiveController controller = Get.put(LiveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // 根据状态切换不同界面
        switch (controller.currentState.value) {
          case 0:
            return _buildLoginView();
          case 1:
            return _buildHistoryView();
          case 2:
            return _buildPrepareView();
          case 3:
            return _buildStreamingView(context);
          case 4:
            return _buildEndView();
          default:
            return _buildLoginView();
        }
      }),
    );
  }

  // --- 1. 登录页面 ---
  Widget _buildLoginView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _backgroundDecoration(),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(), // 防止回弹时露出空白
        child: Column(
          children: [
            SizedBox(height: 58),
            Text("登录",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 120),
            _buildLogo(),
            SizedBox(height: 60),
            _buildTextField(
                "请输入账号", textController: controller.accountController),
            SizedBox(height: 20),
            _buildTextField("请输入密码", isObscure: true,
                textController: controller.passwordController),
            SizedBox(height: 40),
            _buildMainButton("登录", () => controller.login()),
            SizedBox(height: 16),
            _buildProtocol(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 2. 直播记录页面 ---
  Widget _buildHistoryView() {
    controller.getLiveHistory();
    return Container(
      decoration: _backgroundDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("开始直播",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Row(children: [
                // _buildSmallBtn("帮助"),
                SizedBox(width: 10),
                _buildSmallBtn("退出"),
              ]),
            ],
          ),
          SizedBox(height: 40),
          Center(
              child: Image.asset(
                "assets/images/zhibo.png",
                width: 111,
                height: 87,
              )),
          SizedBox(height: 20),
          _buildStartLiveButton("开始直播", () => controller.startLive()),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ColoredBox(
                color: Color(0xFF6F7DE8),
                child: SizedBox(width: 8, height: 20),
              ),
              SizedBox(
                width: 20,
              ),
              Text("直播历史",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          Expanded(
              child: // 使用 Obx 包装，这样当 hsitorytList.value 改变时，UI 会自动刷新
              Obx(() {
                // 如果正在加载或列表为空的友好处理
                if (controller.hsitorytList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("暂无直播记录",
                          style: TextStyle(color: Colors.white38)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  // 如果在 SingleChildScrollView 中，建议禁用滑动
                  padding: EdgeInsets.zero,
                  itemCount: controller.hsitorytList.length,
                  // 动态长度
                  itemBuilder: (context, index) {
                    // 获取当前索引的数据模型
                    var item = controller.hsitorytList[index];
                    // 传递给 Item 构建函数
                    return _buildHistoryItem(
                        item, index, controller.hsitorytList.length);
                  },
                );
              })
          ),
        ],
      ),
    );
  }

  // --- 3. 准备/直播中页面 (背景图) ---
  Widget _buildPrepareView() {
    return Stack(
      children: [
        _buildImageBackground(),
        Positioned(
            top: 60,
            left: 20,
            child: Row(
              children: [
                GestureDetector(
                    onTap: () => controller.currentState.value = 1,
                    child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                SizedBox(width: 0),
                Image.asset(
                  "assets/images/logo.png",
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 5),
                Text("元界主播", style: TextStyle(color: Colors.white)),
              ],
            )),
        Positioned(
          bottom: 220,
          left: 10,
          right: 10,
          child: _buildTextField("请输入设备码", isTranslucent: true,
              textController: controller.deviceCodeController),
        ),
        Positioned(
            bottom: 140,
            left: 30,
            right: 30,
            child: _buildStartLiveButton(
                "进入直播", () => controller.goLive())),
      ],
    );
  }

  Widget _buildStreamingView(BuildContext context) {
    // 1. 计算布局参数
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;

    // 2. 处理 AlivcPusherPreviewType 逻辑
    dynamic viewType; // 根据 SDK 实际类型定义
    if (Platform.isAndroid) {
      // 对应示例中的 widget.store.state.livePushMode
      viewType = controller.livePushMode.value == 0
          ? AlivcPusherPreviewType.base
          : AlivcPusherPreviewType.push;
    } else {
      viewType = AlivcPusherPreviewType.push;
    }

    return Stack(
      children: [
        // --- 底层：摄像头预览层 ---
        Container(
          color: Colors.black,
          width: width,
          height: height,
          child: AlivcPusherPreview(
            viewType: viewType,
            onCreated: (id) => controller.onPreviewCreated(id),
            x: 0.0,
            y: 0.0,
            width: width,
            height: height,
          ),
        ),
        Positioned(
            top: 40,
            left: 20,
            right: 5,
            child: Row(
              children: [
                GestureDetector(
                    onTap: () => controller.currentState.value = 1,
                    child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                SizedBox(width: 0),
                Image.asset(
                  "assets/images/logo.png",
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 5),
                Text("元界主播", style: TextStyle(color: Colors.white)),

                Spacer(),
                // 中间：开播时长
                Obx(() {
                  bool isPushing = controller.isPushing.value;
                  return Visibility(
                    visible: isPushing, // 这里控制显示隐藏
                    child: Text("已开播: "+controller.liveDuration.value,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
                  );
                }),
                SizedBox(width: 5),
                // 右侧：结束按钮
                ElevatedButton(
                  onPressed: () => controller.endLive(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: Colors.black26,

                    // 兼容旧版本背景
                    foregroundColor: Colors.white,
                    // 兼容旧版本文字
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white24)),
                    elevation: 0,
                  ),
                  child: Text("结束直播", style: TextStyle(fontSize: 10.6)),
                )
              ],
            )),
        // --- 顶层：UI 控制层 ---
        // Positioned(
        //   top: 60,
        //   left: 20,
        //   right: 20,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       // 左侧：主播头像与 ID
        //       Container(
        //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //         decoration: BoxDecoration(
        //           color: Colors.black45,
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //         child: Row(
        //           children: [
        //             CircleAvatar(
        //                 radius: 12,
        //                 backgroundColor: Colors.indigoAccent,
        //                 child:
        //                 Icon(Icons.person, size: 16, color: Colors.white)),
        //             SizedBox(width: 8),
        //             GestureDetector(
        //                 onTap: () => controller.startPush(),
        //                 child: Text("元界主播",
        //                     style:
        //                     TextStyle(color: Colors.white, fontSize: 14))),
        //           ],
        //         ),
        //       ),
        //
        //
        //     ],
        //   ),
        // ),

        Obx(() {
          bool isPushing = controller.isPushing.value;
          // Positioned 必须是 Stack 的直接子插件（或被 Obx 包裹的第一个插件）
          return Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Visibility(
              visible: !isPushing, // 这里控制显示隐藏
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.reverseCamera(),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Image.asset("assets/images/icon_jingtou.png"),
                  ),
                ),
              ),
            ),
          );
        }),

        Obx(() {
          bool isPushing = controller.isPushing.value;
          return Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Visibility(
                visible: !isPushing, // 这里控制显示隐藏
                child: _buildStartLiveButton(
                    "开始直播", () => controller.startPush()),
              ));
        }),
      ],
    );
  }

  // --- 4. 直播结束页面 ---
  Widget _buildEndView() {
    return Container(
      decoration: _backgroundDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(),
          SizedBox(height: 40),
          Text("直播结束", style: TextStyle(color: Colors.white, fontSize: 24)),
          SizedBox(height: 4),
          Text("时长: ${controller.liveDuration.value}",
              style: TextStyle(color: Colors.white38)),
          SizedBox(height: 60),
          _buildMainButton("确定", () => controller.backToHistory()),
        ],
      ),
    );
  }

  // --- 公用组件方法 ---

  BoxDecoration _backgroundDecoration() {
    return BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/biejng.png"),
          fit: BoxFit.cover,
        ));
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset("assets/images/logo.png"),
        SizedBox(height: 20),
        Text("元界主播",
            style: TextStyle(
                color: Colors.white38,
                fontSize: 20,
                fontWeight: FontWeight.normal)),
      ],
    );
  }

  Widget _buildTextField(String hint,
      {bool isObscure = false, bool isTranslucent = false, TextEditingController? textController}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 45,
        child: TextField(
          controller: textController,
          // 绑定控制器
          obscureText: isObscure,
          textAlignVertical: TextAlignVertical.center,
          //
          style: TextStyle(
              color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
            filled: true,
            // isDense: true,
            // 调整内边距，数值越小，输入框越矮
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            fillColor: isTranslucent ? Colors.black45 : Colors.white10,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildStartLiveButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6F7DE8), // 旧版本使用 primary
            foregroundColor: Colors.white, // 文字颜色
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child:
          Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6F7DE8), // 旧版本使用 primary
            foregroundColor: Colors.white, // 文字颜色
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child:
          Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildProtocol() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() =>
            GestureDetector(
              onTap: () =>
              controller.isAgreed.value = !controller.isAgreed.value,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    // 选中时边框也是白色，未选中时灰色
                    color: controller.isAgreed.value
                        ? Colors.white
                        : Colors.white54,
                    width: 1.0,
                  ),
                  // 关键点：选中时底色设为白色
                  color: controller.isAgreed.value
                      ? Colors.white
                      : Colors.transparent,
                ),
                child: controller.isAgreed.value
                    ? Icon(
                  Icons.check,
                  size: 12,
                  // 关键点：图标颜色设置为透明，或者设置为你背景图片的深蓝色
                  // 如果你想看穿背景，这里设置为透明即可（Icon 默认不支持挖空，所以通常设为深色背景色）
                  color: Color(0xFF1A1A2E),
                )
                    : null,
              ),
            )),
        SizedBox(width: 8),
        Text(
          "我已阅读并同意《服务协议》和《隐私政策》",
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(LiveItem liveItem, int index, int totalCount) {
    return Container(
      // 为了虚线连续，移除item之间的间隔
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 20, // 固定宽度
          child: CustomPaint(
            painter: DashedLinePainter(
              drawTopHalf: index > 0, // 第一个item不绘制上半部分
              drawBottomHalf: index < totalCount - 1, // 最后一个item不绘制下半部分
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black54,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          liveItem.formattedDate,
          // "12月${14 - index}日",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          liveItem.formattedTimeRange,
          // "20:00-24:00",
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildImageBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        "assets/images/jiemian.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSmallBtn(String text) {
    return GestureDetector(
      onTap: () {
        exit(0);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child:
        Text(text, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }
}
