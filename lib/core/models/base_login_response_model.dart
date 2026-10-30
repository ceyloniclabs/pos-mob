class BaseLoginResponseModel<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? token;

  BaseLoginResponseModel({
    required this.success,
    this.data,
    this.message,
    this.token,
  });

  factory BaseLoginResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return BaseLoginResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: json['user'] != null ? fromJsonT(json['user']) : null,
      token: json['token']?.toString() ?? json['access_token']?.toString(),
    );
  }
}
