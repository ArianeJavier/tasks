import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskController {
  final supabase = Supabase.instance.client;

  Future<List<Task>> fetchTasks() async {
    final response = await supabase.from('tasks').select();
    return (response as List).map((data) => Task.fromMap(data)).toList();
  }

  Future<void> addTask(Task task) async {
    await supabase.from('tasks').insert(task.toMap());
  }

  Future<void> updateTask(int id, Task task) async {
    await supabase.from('tasks').update(task.toMap()).eq('id', id);
  }

  Future<void> deleteTask(int id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
