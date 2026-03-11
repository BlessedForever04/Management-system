class Activity {
  String? id;
  String userName;
  String verb;
  String projectName;
  DateTime? time;

  Activity({
    this.id,
    required this.userName,
    required this.verb,
    required this.projectName,
    this.time,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      userName: json['userName'] ?? '',
      verb: json['verb'] ?? '',
      projectName: json['projectName'] ?? '',
      time: json['time'] != null
          ? DateTime.tryParse(json['time'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'verb': verb,
      'projectName': projectName,
    };
  }
}
