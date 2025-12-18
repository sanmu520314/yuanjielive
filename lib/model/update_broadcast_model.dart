class UpdateBroadcastResponse {
  String? msg;
  int? status;

  UpdateBroadcastResponse({this.msg, this.status});

  UpdateBroadcastResponse.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];
  }
}

