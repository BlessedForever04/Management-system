class Member {
  String? id;
  String name;
  List<String> tasks;

  Member({ this.id, required this.name, required this.tasks});

  factory Member.fromJson(Map<String , dynamic>json){
    return Member(id: json['id'], name: json['name'], tasks: List<String>.from(json['tasks'] ?? []));
  }

  Map<String , dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "tasks" : tasks
    };
  }
}
