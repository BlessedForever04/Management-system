class AppNotification {
  final String? id;
  final String message;
  final DateTime? time;
  final String eventType;
  final String? helperId;
  final String? userId;
  final bool isRead;
  final bool isDeleted;

  const AppNotification({
    this.id,
    required this.message,
    required this.time,
    required this.eventType,
    this.helperId,
    this.userId,
    this.isRead = false,
    this.isDeleted = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString(),
      message: (json['message'] ?? '').toString(),
      time: _parseBackendDateTime(json['time']),
      eventType: (json['type'] ?? json['eventType'] ?? '').toString(),
      helperId: json['helperId']?.toString(),
      userId: json['userId']?.toString(),
      isRead: _parseBool(json['isRead'] ?? json['read']),
      isDeleted: _parseBool(json['isDeleted'] ?? json['deleted']),
    );
  }

  AppNotification copyWith({
    String? id,
    String? message,
    DateTime? time,
    String? eventType,
    String? helperId,
    String? userId,
    bool? isRead,
    bool? isDeleted,
  }) {
    return AppNotification(
      id: id ?? this.id,
      message: message ?? this.message,
      time: time ?? this.time,
      eventType: eventType ?? this.eventType,
      helperId: helperId ?? this.helperId,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static DateTime? _parseBackendDateTime(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    // Handles array format like [2026,3,29,15,13,17,123000000]
    if (value is List && value.length >= 6) {
      final year = _toInt(value[0]);
      final month = _toInt(value[1]);
      final day = _toInt(value[2]);
      final hour = _toInt(value[3]);
      final minute = _toInt(value[4]);
      final second = _toInt(value[5]);
      final nanos = value.length > 6 ? _toInt(value[6]) : 0;

      if (year == null ||
          month == null ||
          day == null ||
          hour == null ||
          minute == null ||
          second == null) {
        return null;
      }
      if (nanos != null) {
        final microseconds = (nanos / 1000).round();
        return DateTime(
          year,
          month,
          day,
          hour,
          minute,
          second,
        ).add(Duration(microseconds: microseconds));
      }
    }

    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}
