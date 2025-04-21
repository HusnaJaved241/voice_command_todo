class TodoModel {
  final String title;
  late final bool isDone;

  TodoModel({required this.title, required this.isDone});

  Map<String, dynamic> toJson() {
    return {'title': title, 'isDone': isDone};
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(title: json['title'], isDone: json['isDone']);
  }
}
