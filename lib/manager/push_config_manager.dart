import 'package:flutter_livepush_plugin/pusher/live_push_def.dart';

enum PushConfigPageType {
  basic,
  interactive,
}

class ConfigSegmentBarItemData {
  String title = "";
  String icon = "";
  String selectedIcon = "";

  static ConfigSegmentBarItemData create(String title,
      {String? icon, String? selectedIcon}) {
    ConfigSegmentBarItemData data = ConfigSegmentBarItemData();
    data.title = title;
    data.icon = icon ?? "";
    data.selectedIcon = selectedIcon ?? "";
    return data;
  }
}

List<ConfigSegmentBarItemData> segmentItems = [
  ConfigSegmentBarItemData.create("push_parameters"),
  ConfigSegmentBarItemData.create("push_features"),
];

const Map<AlivcLivePushResolution, String> resolutionItems = {
  AlivcLivePushResolution.resolution_180P: "180P",
  AlivcLivePushResolution.resolution_240P: "240P",
  AlivcLivePushResolution.resolution_360P: "360P",
  AlivcLivePushResolution.resolution_480P: "480P",
  AlivcLivePushResolution.resolution_540P: "540P",
  AlivcLivePushResolution.resolution_720P: "720P",
  AlivcLivePushResolution.resolution_1080P: "1080P",
};

const Map<AlivcLivePushQualityMode, String> qualityModeItems = {
  AlivcLivePushQualityMode.resolution_first: "resolution_first",
  AlivcLivePushQualityMode.fluency_first: "fluency_first",
  AlivcLivePushQualityMode.custom: "custom",
};

const Map<AlivcLivePushAudioChannel, String> audioChannelItems = {
  AlivcLivePushAudioChannel.audio_channel_one: "single_track",
  AlivcLivePushAudioChannel.audio_channel_two: "dual_track",
};

const Map<AlivcLivePushVideoEncoderModeHardCodec, String>
    videoHardEncoderCodecItems = {
  AlivcLivePushVideoEncoderModeHardCodec.h264: "H264",
  AlivcLivePushVideoEncoderModeHardCodec.h265: "H265",
};

const Map<AlivcLivePushOrientation, String> orientationItems = {
  AlivcLivePushOrientation.portrait: "portrait",
  AlivcLivePushOrientation.landscape_home_left: "landscape_left",
  AlivcLivePushOrientation.landscape_home_right: "landscape_right",
};

const Map<AlivcPusherPreviewDisplayMode, String> previewDisplayModeItems = {
  AlivcPusherPreviewDisplayMode.preview_scale_fill: "stretched",
  AlivcPusherPreviewDisplayMode.preview_aspect_fit: "fit",
  AlivcPusherPreviewDisplayMode.preview_aspect_fill: "cropped",
};

const Map<AlivcLivePushStreamMode, String> pushStreamingModeItems = {
  AlivcLivePushStreamMode.video_and_audio: "audio_and_video",
  AlivcLivePushStreamMode.audio_only: "audio_only",
  AlivcLivePushStreamMode.video_only: "video_only",
};

enum ConfigItemType {
  resolution,
  qualityModeConfig,
  audioEncoderProfile,
  audioChannel,
  videoHardEncoderCodec,
  minFps,
  fps,
  audioSampleRate,
  orientation,
  previewDisplayMode,
  pushStreamingMode,
}

class ConfigItemValue {
  Map items = {};
  int intV = 0;
  String stringV = "";

  static ConfigItemValue init(Map items, int? intV) {
    ConfigItemValue value = ConfigItemValue();
    value.items = items;
    if (intV != null) {
      value.intV = intV;
    } else {
      value.intV = 0;
    }

    value.stringV = _getMapValueWithIndex(items, intV ?? 0);
    return value;
  }

  void updateValue(int intV) {
    this.intV = intV;
    this.stringV = _getMapValueWithIndex(items, intV);
  }

  static dynamic _getMapValueWithIndex(Map map, int index) {
    List mapKey = map.keys.toList();
    return map[mapKey[index]];
  }

  static ConfigItemValue create(ConfigItemType type) {
    switch (type) {
      case ConfigItemType.resolution:
        return init(resolutionItems, 4);
        break;
      case ConfigItemType.qualityModeConfig:
        return init(qualityModeItems, 0);
        break;
      case ConfigItemType.audioEncoderProfile:
        return init(AudioEncoderProfileData.items, 0);
        break;
      case ConfigItemType.audioChannel:
        return init(audioChannelItems, 0);
        break;
      case ConfigItemType.videoHardEncoderCodec:
        return init(videoHardEncoderCodecItems, 0);
        break;
      case ConfigItemType.minFps:
        return init(FPSData.fpsItems, AlivcLivePushFPS.fps_8.index);
        break;
      case ConfigItemType.fps:
        return init(FPSData.fpsItems, AlivcLivePushFPS.fps_20.index);
        break;
      case ConfigItemType.audioSampleRate:
        return init(AudioSampleRateData.items, 3);
        break;
      case ConfigItemType.orientation:
        return init(orientationItems, 0);
        break;
      case ConfigItemType.previewDisplayMode:
        return init(previewDisplayModeItems, 1);
        break;
      case ConfigItemType.pushStreamingMode:
        return init(pushStreamingModeItems, 0);
        break;
    }
  }

  static bool intToBool(int value) {
    return value == 0 ? false : true;
  }

  static int boolToInt(bool value) {
    return value == true ? 1 : 0;
  }
}

class ConfigData {
  // 推流url
  late String pushURL;

  // 设置参数
  late int selectSegmentIndex;

  // 互动模式
  late int livePushMode;

  // 分辨率
  late ConfigItemValue resolution;

  // 码率自适应
  late bool enableAutoBitrate;

  // 分辨率自适应
  late bool enableAutoResolution;

  // 高级设置
  late bool advanced;

  // 码率模式
  late ConfigItemValue qualityMode;

  // 视频目标码率
  late int targetVideoBitrate;

  // 视频最小码率
  late int minVideoBitrate;

  // 视频初始码率
  late int initialVideoBitrate;

  // 音频码率
  late int audioBitrate;

  // 最小帧率
  late ConfigItemValue minFps;

  // 采集帧率
  late ConfigItemValue fps;

  // 音频采样率
  late ConfigItemValue audioSampleRate;

  // 关键帧间隔
  late int videoEncodeGop;

  // 音频格式
  late ConfigItemValue audioEncoderProfile;

  // 声道数
  late ConfigItemValue audioChannel;

  // 音频编码
  late int audioEncoderMode;

  // 视频编码
  late int videoEncoderMode;

  // 视频硬编Codec
  late ConfigItemValue videoHardEncoderCodec;

  // B-Frame
  late bool openBFrame;

  // 推流方向
  late ConfigItemValue orientation;

  // 显示模式
  late ConfigItemValue previewDisplayMode;

  // 重连时长
  late double connectRetryInterval;

  // 重连次数
  late int connectRetryCount;

  // 推流镜像
  late bool pushMirror;

  // 预览镜像
  late bool previewMirror;

  // 摄像头类型
  late int cameraType;

  // 自动聚焦
  late bool autoFocus;

  // 美颜
  late bool beautyOn;

  // 暂停图片
  late bool openPauseImg;

  // 网络差图片
  late bool openNetworkPoorImg;

  // 推流模式
  late ConfigItemValue pushStreamingMode;

  // 本地日志
  late bool openLog;

  static ConfigData? _instance;

  ConfigData._() {}

  static ConfigData _getInstance() {
    _instance ??= ConfigData._();
    return _instance!;
  }

  factory ConfigData() => _getInstance();

  static void resetData() {
    ConfigData configData = ConfigData();
    configData.pushURL = "";
    configData.selectSegmentIndex = 0;
    configData.livePushMode = 0;
    configData.resolution = ConfigItemValue.create(ConfigItemType.resolution);
    configData.enableAutoBitrate = true;
    configData.enableAutoResolution = false;
    configData.advanced = false;
    configData.qualityMode =
        ConfigItemValue.create(ConfigItemType.qualityModeConfig);
    configData.targetVideoBitrate = 1400;
    configData.minVideoBitrate = 600;
    configData.initialVideoBitrate = 1500;
    configData.audioBitrate = 64;
    configData.minFps = ConfigItemValue.create(ConfigItemType.minFps);
    configData.fps = ConfigItemValue.create(ConfigItemType.fps);
    configData.audioSampleRate =
        ConfigItemValue.create(ConfigItemType.audioSampleRate);
    configData.videoEncodeGop = 2;
    configData.audioEncoderProfile =
        ConfigItemValue.create(ConfigItemType.audioEncoderProfile);
    configData.audioChannel =
        ConfigItemValue.create(ConfigItemType.audioChannel);
    configData.audioEncoderMode = 1;
    configData.videoEncoderMode = 0;
    configData.videoHardEncoderCodec =
        ConfigItemValue.create(ConfigItemType.videoHardEncoderCodec);
    configData.openBFrame = false;
    configData.orientation = ConfigItemValue.create(ConfigItemType.orientation);
    configData.previewDisplayMode =
        ConfigItemValue.create(ConfigItemType.previewDisplayMode);
    configData.connectRetryInterval = 1000;
    configData.connectRetryCount = 5;
    configData.pushMirror = false;
    configData.previewMirror = false;
    configData.cameraType = 1;
    configData.autoFocus = true;
    configData.beautyOn = true;
    configData.openPauseImg = false;
    configData.openNetworkPoorImg = false;
    configData.pushStreamingMode =
        ConfigItemValue.create(ConfigItemType.pushStreamingMode);
    configData.openLog = false;
  }

  updateVideoBitrateValueWithFixQualityMode(int qualityMode) {
    if (qualityMode == 0) {
      switch (this.resolution.intV) {
        case 0:
          {
            this.targetVideoBitrate = 550;
            this.minVideoBitrate = 120;
            this.initialVideoBitrate = 300;
          }
          break;
        case 1:
          {
            this.targetVideoBitrate = 750;
            this.minVideoBitrate = 180;
            this.initialVideoBitrate = 450;
          }
          break;
        case 2:
          {
            this.targetVideoBitrate = 1000;
            this.minVideoBitrate = 300;
            this.initialVideoBitrate = 600;
          }
          break;
        case 3:
          {
            this.targetVideoBitrate = 1200;
            this.minVideoBitrate = 300;
            this.initialVideoBitrate = 800;
          }
          break;
        case 4:
          {
            this.targetVideoBitrate = 1400;
            this.minVideoBitrate = 600;
            this.initialVideoBitrate = 1000;
          }
          break;
        case 5:
          {
            this.targetVideoBitrate = 2000;
            this.minVideoBitrate = 600;
            this.initialVideoBitrate = 1500;
          }
          break;
        case 6:
          {
            this.targetVideoBitrate = 2500;
            this.minVideoBitrate = 1200;
            this.initialVideoBitrate = 1800;
          }
          break;
      }
      this.fps.updateValue(AlivcLivePushFPS.fps_20.index);
    } else if (qualityMode == 1) {
      switch (this.resolution.intV) {
        case 0:
          {
            this.targetVideoBitrate = 250;
            this.minVideoBitrate = 80;
            this.initialVideoBitrate = 200;
          }
          break;
        case 1:
          {
            this.targetVideoBitrate = 350;
            this.minVideoBitrate = 120;
            this.initialVideoBitrate = 300;
          }
          break;
        case 2:
          {
            this.targetVideoBitrate = 600;
            this.minVideoBitrate = 200;
            this.initialVideoBitrate = 400;
          }
          break;
        case 3:
          {
            this.targetVideoBitrate = 800;
            this.minVideoBitrate = 300;
            this.initialVideoBitrate = 600;
          }
          break;
        case 4:
          {
            this.targetVideoBitrate = 1000;
            this.minVideoBitrate = 300;
            this.initialVideoBitrate = 800;
          }
          break;
        case 5:
          {
            this.targetVideoBitrate = 1200;
            this.minVideoBitrate = 300;
            this.initialVideoBitrate = 1000;
          }
          break;
        case 6:
          {
            this.targetVideoBitrate = 2200;
            this.minVideoBitrate = 1200;
            this.initialVideoBitrate = 1500;
          }
          break;
      }
      this.fps.updateValue(AlivcLivePushFPS.fps_25.index);
    }
  }
}
