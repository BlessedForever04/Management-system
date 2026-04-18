import 'dart:convert';

import 'package:managementt/model/app_notification.dart';
import 'package:managementt/service/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<List<AppNotification>> getNotifications(String memberId) async {
    final candidatePaths = <String>[
      '/members/notification/$memberId',
      '/notification/$memberId',
    ];

    Object? lastError;

    for (final path in candidatePaths) {
      try {
        final response = await _api.get(path);

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            return decoded
                .whereType<Map<String, dynamic>>()
                .map(AppNotification.fromJson)
                .where((notification) {
                  final userId = (notification.userId ?? '').trim();
                  final belongsToMember = userId.isEmpty || userId == memberId;
                  return belongsToMember && !notification.isDeleted;
                })
                .toList();
          }
          throw Exception('Invalid notifications response format from $path');
        }

        if (_isNoNotificationsResponse(response.statusCode, response.body)) {
          return const <AppNotification>[];
        }

        if (response.statusCode == 404 && path != candidatePaths.last) {
          // Try the next known route variation before failing.
          continue;
        }

        throw Exception(
          'GET $path failed with ${response.statusCode}: '
          '${response.body.isNotEmpty ? response.body : 'No response body'}',
        );
      } catch (e) {
        lastError = e;
        if (path == candidatePaths.last) {
          break;
        }
      }
    }

    throw Exception(lastError?.toString() ?? 'Failed to load notifications');
  }

  Future<void> deleteNotification(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) {
      throw Exception('Notification id is required for delete operation.');
    }

    final deleteResponse = await _api.delete('/notification/softDelete/$id');
    if (_isDeleteSuccess(deleteResponse.statusCode)) {
      return;
    }

    throw Exception(
      'Failed to delete notification: '
      '${deleteResponse.statusCode} '
      '${deleteResponse.body.isNotEmpty ? deleteResponse.body : 'No response body'}',
    );
  }

  Future<int> getUnreadNotificationCount(String memberId) async {
    final id = memberId.trim();
    if (id.isEmpty) {
      return 0;
    }

    try {
      final response = await _api.get('/notification/unReadCount/$id');
      if (response.statusCode == 200) {
        return _parseUnreadCount(response.body);
      }

      if (_isNoNotificationsResponse(response.statusCode, response.body)) {
        return 0;
      }
    } catch (_) {
      // Fallback to client-side count below.
    }

    final notifications = await getNotifications(id);
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) {
      return;
    }

    final updateResponse = await _api.put(
      '/notification/update/$id',
      body: {'isRead': true},
    );

    if (_isWriteSuccess(updateResponse.statusCode)) {
      return;
    }

    throw Exception(
      'Failed to mark notification as read: '
      '${updateResponse.statusCode} '
      '${updateResponse.body.isNotEmpty ? updateResponse.body : 'No response body'}',
    );
  }

  Future<void> markNotificationsAsRead(Iterable<String> notificationIds) async {
    final ids = notificationIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (ids.isEmpty) {
      return;
    }

    await Future.wait(ids.map(markNotificationAsRead));
  }

  bool _isNoNotificationsResponse(int statusCode, String body) {
    if (statusCode == 404 || statusCode == 204) {
      return true;
    }

    if (statusCode == 500) {
      final lowered = body.toLowerCase();
      if (lowered.contains('no notifications found')) {
        return true;
      }
    }

    return false;
  }

  bool _isDeleteSuccess(int statusCode) {
    return statusCode == 200 || statusCode == 204;
  }

  bool _isWriteSuccess(int statusCode) {
    return statusCode == 200 || statusCode == 201 || statusCode == 204;
  }

  int _parseUnreadCount(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    final asInt = int.tryParse(trimmed);
    if (asInt != null) {
      return asInt;
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is num) {
      return decoded.toInt();
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = <dynamic>[
        decoded['count'],
        decoded['unreadCount'],
        decoded['unReadCount'],
        decoded['value'],
      ];

      for (final candidate in candidates) {
        if (candidate is num) {
          return candidate.toInt();
        }
        final parsed = int.tryParse(candidate?.toString() ?? '');
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }
}
