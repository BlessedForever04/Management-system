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

}
