class ToBroadcastResponse {
  String? msg;
  CastData? data;
  int? status;

  ToBroadcastResponse({this.msg, this.data, this.status});

  ToBroadcastResponse.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    data = json['data'] != null ? CastData.fromJson(json['data']) : null;
    status = json['status'];
  }
}

class CastData {
  String? pushUrl; // 推流地址（主播用）
  String? rtmpUrl; // 拉流地址（观众用）
  int? id;
  int? status;

  CastData({this.pushUrl, this.rtmpUrl, this.id, this.status});

  CastData.fromJson(Map<String, dynamic> json) {
    pushUrl = json['pushUrl'];
    rtmpUrl = json['rtmpUrl'];
    id = json['id'];
    status = json['status'];
  }
}