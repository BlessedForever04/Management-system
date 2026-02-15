class Task {
  String? id;
  String title;
  String description;
  String? priority;
  String? status;
  String owner;
  String? remark;
  // have to add task priority too

  Task({
    this.id,
    required this.title,
    required this.description,
    this.priority,
    this.status,
    required this.owner,
    this.remark,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      owner: json['owner'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "priority": priority,
      "status": status,
      "owner": owner,
      "remark": remark,
    };
  }
}
