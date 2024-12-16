import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import 'add_edit_task_view.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TaskController _controller = TaskController();
  late Future<List<Task>> _tasks;
  bool isGridView = true; // Default view is Grid View

  @override
  void initState() {
    super.initState();
    _tasks = _controller.fetchTasks();
  }

  void _refreshList() {
    setState(() {
      _tasks = _controller.fetchTasks();
    });
  }

  void _moveUpdatedTaskToFirst(Task updatedTask) {
    setState(() {
      _tasks = Future.value(
        _controller.fetchTasks().then((tasks) {
          tasks.removeWhere((task) => task.id == updatedTask.id);
          tasks.insert(0, updatedTask);
          return tasks;
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontFamily: 'TimesNewRoman',
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF00796B), // Teal
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView; // Toggle the view mode
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'TimesNewRoman'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found.',
                style: TextStyle(fontFamily: 'TimesNewRoman'),
              ),
            );
          }

          final tasks = snapshot.data!;

          return isGridView
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 600) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 900) {
                      crossAxisCount = 2;
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailView(task: task),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white, // White background
                            shadowColor: Colors.black.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: const Color(0xFFB2DFDB), // Light Teal
                                        value: task.completed,
                                        onChanged: (bool? value) async {
                                          final updatedTask = task.copyWith(completed: value!);
                                          await _controller.updateTask(task.id!, updatedTask);
                                          _moveUpdatedTaskToFirst(updatedTask);
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'TimesNewRoman',
                                            color: Color(0xFF212121), // Dark Gray
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'TimesNewRoman',
                                      color: Color(0xFF757575), // Light Gray
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Description: ${task.description}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575), // Light Gray
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: const Color(0xFF9575CD), // Purple
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) {
                                                return AddEditTaskView(task: task);
                                              },
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;
                                                var tween = Tween(begin: begin, end: end)
                                                    .chain(CurveTween(curve: curve));
                                                var offsetAnimation = animation.drive(tween);
                                                return SlideTransition(position: offsetAnimation, child: child);
                                              },
                                            ),
                                          );
                                          _refreshList();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: const Color(0xFFE57373), // Red
                                        onPressed: () async {
                                          await _controller.deleteTask(task.id!);
                                          _refreshList();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailView(task: task),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Checkbox(
                          activeColor: const Color(0xFFB2DFDB), // Light Teal
                          value: task.completed,
                          onChanged: (bool? value) async {
                            final updatedTask = task.copyWith(completed: value!);
                            await _controller.updateTask(task.id!, updatedTask);
                            _moveUpdatedTaskToFirst(updatedTask);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'TimesNewRoman',
                          ),
                        ),
                        subtitle: Text(
                          'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575), // Light Gray
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditTaskView(task: task),
                                  ),
                                );
                                _refreshList();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _controller.deleteTask(task.id!);
                                _refreshList();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 219, 234, 232), // Light Teal
        child: const Icon(Icons.add, color: Color.fromARGB(255, 6, 6, 6), size: 30),
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return const AddEditTaskView();
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
          _refreshList();
        },
      ),
    );
  }
}

// Task Detail View for displaying title, description, and due date
class TaskDetailView extends StatelessWidget {
  final Task task;
  const TaskDetailView({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${task.title}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: ${task.description}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Due Date: ${task.dueDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
