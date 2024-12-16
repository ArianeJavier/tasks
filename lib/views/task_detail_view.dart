import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import 'add_edit_task_view.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TaskController _controller = TaskController();
  late Future<List<Task>> _tasks;

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

  // Function to handle update of task and ensure it appears first
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
        title: const Text('Tasks'),
        elevation: 4,
        backgroundColor: const Color(0xFF3E5C76), // Elegant deep blue
        centerTitle: true,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          final tasks = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Determine number of columns based on screen width
              int crossAxisCount = 4; // Default to 4 columns
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1; // Single column for small screens
              } else if (constraints.maxWidth < 900) {
                crossAxisCount = 2; // Two columns for medium screens
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Responsive columns
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio:
                      1.1, // Slightly rectangular for better content fitting
                ),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color(0xFFF5F5F5), // Elegant light gray
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row for checkbox and task title
                          Row(
                            children: [
                              Checkbox(
                                activeColor: const Color(
                                    0xFFB79B9C), // Soft pastel purple
                                value: task.completed,
                                onChanged: (bool? value) async {
                                  final updatedTask =
                                      task.copyWith(completed: value!);
                                  await _controller.updateTask(
                                      task.id!, updatedTask);
                                  _moveUpdatedTaskToFirst(updatedTask);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Color(0xFF4B4B4B), // Elegant deep gray
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // Handle overflow
                                  maxLines: 2, // Limit title to 2 lines
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Description wrapped in Expanded or Flexible
                          Flexible(
                            child: Text(
                              task.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7A7A7A), // Softer medium gray
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Handle overflow
                              maxLines: 3, // Limit description to 3 lines
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF66B2B2), // Muted teal
                            ),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                            maxLines: 1, // Limit due date to 1 line
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: const Color(0xFF9E7BB5), // Soft lavender
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return AddEditTaskView(task: task);
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                            position: offsetAnimation,
                                            child: child);
                                      },
                                    ),
                                  );
                                  _refreshList();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: const Color(0xFFEC7C7C), // Muted red
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
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF66B2B2), // Muted teal
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return const AddEditTaskView();
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
    );
  }
}

extension on Task {
  // Helper method to create a placeholder task
}
