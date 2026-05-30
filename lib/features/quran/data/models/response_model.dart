class ResponseModel<T> {
  int code;
  String status;
  T data;

  ResponseModel({required this.code, required this.status, required this.data});

  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ResponseModel<T>(
      code: json["code"],
      status: json["status"],
      data: fromJsonT(json["data"]),
    );
  }
}
