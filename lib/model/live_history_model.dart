import 'package:intl/intl.dart';

class LiveHistoryResponse {
  String? msg;
  int? status;
  List<LiveItem>? data;

  LiveHistoryResponse({this.msg, this.status, this.data});

  LiveHistoryResponse.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];
    if (json['data'] != null) {
      data = <LiveItem>[];
      json['data'].forEach((v) {
        data!.add(LiveItem.fromJson(v));
      });
    }
  }
}

class LiveItem {
  String? accountName;
  String? rtmpUrl;
  String? nickName;
  String? deviceCode;
  String? deviceName;
  String? realName;
  String? pushUrl;
  int? expireTime;
  int? createTime;
  int? closeTime;
  int? playTime;
  int? id;
  int? status; // 1: 正在直播, 2: 已结束 (根据你之前的 UI 推测)

  LiveItem({
    this.accountName,
    this.rtmpUrl,
    this.nickName,
    this.deviceCode,
    this.deviceName,
    this.realName,
    this.pushUrl,
    this.expireTime,
    this.createTime,
    this.closeTime,
    this.playTime,
    this.id,
    this.status,
  });

  LiveItem.fromJson(Map<String, dynamic> json) {
    accountName = json['accountName'];
    rtmpUrl = json['rtmpUrl'];
    nickName = json['nickName'];
    deviceCode = json['deviceCode'];
    deviceName = json['deviceName'];
    realName = json['realName'];
    pushUrl = json['pushUrl'];
    expireTime = json['expireTime'];
    createTime = json['createTime'];
    closeTime = json['closeTime'];
    playTime = json['playTime'];
    id = json['id'];
    status = json['status'];
  }
}


extension LiveItemFormatting on LiveItem {
  // 获取：MM月dd日
  String get formattedDate {
    if (createTime == null) return "--月--日";
    var date = DateTime.fromMillisecondsSinceEpoch(createTime!);
    return DateFormat('MM月dd日').format(date);
  }

  // 获取：HH:mm-HH:mm
  String get formattedTimeRange {
    if (createTime == null || closeTime == null) return "00:00-00:00";

    var start = DateTime.fromMillisecondsSinceEpoch(createTime!);
    var end = DateTime.fromMillisecondsSinceEpoch(closeTime!);

    var startTime = DateFormat('HH:mm').format(start);
    var endTime = DateFormat('HH:mm').format(end);

    return "$startTime-$endTime";
  }
}