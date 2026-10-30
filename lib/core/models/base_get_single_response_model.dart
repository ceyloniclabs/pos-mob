class BaseGetSingleResponseModel<T> {
  final bool success;
  final T? data;
  final String? message;

  BaseGetSingleResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory BaseGetSingleResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return BaseGetSingleResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
