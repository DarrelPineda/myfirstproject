class TodoItem {
  final String task;
  bool done;

  TodoItem({required this.task, this.done = false});

  Map<String, dynamic> toJson() => {'task': task, 'done': done};

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      TodoItem(task: json['task'], done: json['done']);
}
