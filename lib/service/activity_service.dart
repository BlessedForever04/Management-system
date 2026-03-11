import 'dart:convert';
import 'package:managementt/model/activity.dart';
import 'package:managementt/service/api_service.dart';

class ActivityService {
  final ApiService _api = ApiService();

  Future<List<Activity>> getActivities() async {
    final response = await _api.get('/activity/activities');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Activity.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<void> addActivity(Activity activity) async {
    await _api.post('/activity/add', body: activity.toJson());
  }
}
