import 'dart:convert';

/// Represents a parsed QR payload representing a target database table and its record ID.
/// Example JSON: {"table": "rent_surf_boards", "id": 17}
class QrPayload {
  final String table;
  final int id;
  final Map<String, dynamic> rawData;

  const QrPayload({
    required this.table,
    required this.id,
    this.rawData = const {},
  });

  /// Factory constructor to parse payload from a decoded JSON map.
  factory QrPayload.fromJson(Map<String, dynamic> json) {
    final tableValue = json['table'];
    if (tableValue == null || tableValue is! String || tableValue.trim().isEmpty) {
      throw const FormatException("Invalid or missing 'table' property in QR payload.");
    }

    final idValue = json['id'];
    if (idValue == null) {
      throw const FormatException("Invalid or missing 'id' property in QR payload.");
    }

    final int? parsedId = idValue is int ? idValue : int.tryParse(idValue.toString());
    if (parsedId == null) {
      throw FormatException("The 'id' property must be a valid integer: received '$idValue'.");
    }

    return QrPayload(
      table: tableValue.trim().toLowerCase(),
      id: parsedId,
      rawData: json,
    );
  }

  /// Parses a raw QR payload string. Supports standard JSON format.
  factory QrPayload.fromString(String rawPayload) {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      throw const FormatException("Empty QR payload.");
    }

    final dynamic decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException("QR code content is not a valid JSON object.");
    }

    return QrPayload.fromJson(decoded);
  }

  /// Converts this payload to a JSON-encodable Map.
  Map<String, dynamic> toJson() => {
    'table': table,
    'id': id,
  };

  /// Encodes this payload to a JSON string matching the required table format.
  /// Example: '{"table":"rent_surf_boards","id":17}'
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() => 'QrPayload(table: $table, id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrPayload &&
          runtimeType == other.runtimeType &&
          table == other.table &&
          id == other.id;

  @override
  int get hashCode => table.hashCode ^ id.hashCode;
}
