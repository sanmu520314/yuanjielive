// {
// "msg": "登录成功",
// "data": {
// "realName": "2",
// "accountName": "3",
// "nickName": "1",
// "id": 1
// },
// "status": 0
// }

class LoginResponse {
  final String msg;
  final int status;
  final ApiData data;

  LoginResponse({required this.msg, required this.status, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      msg: json['msg'] as String,
      status: json['status'] as int,
      data: ApiData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'msg': msg,
      'status': status,
    };
  }
}

class ApiData {
  final String realName;
  final String accountName;
  final String nickName;
  final int id;

  ApiData(
      {required this.realName,
      required this.accountName,
      required this.nickName,
      required this.id});

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(
        realName: json['realName'] as String,
        accountName: json['accountName'] as String,
        nickName: json['nickName'] as String,
        id: json['id'] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'realName': realName,
      'accountName': accountName,
      'nickName': nickName,
      'id': id,
    };
  }
}
