class Task {
  String? id;
  String title;
  String description;
  String priority;
  String? type; // PROJECT or TASK
  String? status; // NOT_STARTED / TODO / DONE / OVERDUE
  String ownerId;
  String? parentTaskId;
  int progress; // 0-100
  String? remark;
  DateTime? deadLine;
  DateTime? startDate;
  int remainingTask;
  int completedTask;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.type,
    this.status,
    required this.ownerId,
    this.parentTaskId,
    this.progress = 0,
    this.remark,
    this.deadLine,
    this.startDate,
    this.remainingTask = 0,
    this.completedTask = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      type: json['type'],
      status: json['status'],
      ownerId: json['ownerId'] ?? '',
      parentTaskId: json['parentTaskId'],
      progress: json['progress'] ?? 0,
      remark: json['remark'],
      deadLine: json['deadLine'] != null
          ? DateTime.tryParse(json['deadLine'].toString())
          : null,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      remainingTask: json['remainingTask'] ?? 0,
      completedTask: json['completedTask'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "priority": priority,
      "type": type,
      "status": status,
      "ownerId": ownerId,
      "parentTaskId": parentTaskId,
      "progress": progress,
      "remark": remark,
      "deadLine": deadLine?.toIso8601String().split('T').first,
      "startDate": startDate?.toIso8601String().split('T').first,
      "remainingTask": remainingTask,
      "completedTask": completedTask,
    };
  }
}
