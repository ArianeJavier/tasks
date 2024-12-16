import 'package:flutter/material.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';

class AddEditTaskView extends StatefulWidget {
  final Task? task;

  const AddEditTaskView({super.key, this.task});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditTaskViewState createState() => _AddEditTaskViewState();
}

class _AddEditTaskViewState extends State<AddEditTaskView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final TaskController _controller = TaskController();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDateController.text =
          widget.task!.dueDate.toLocal().toString().split(' ')[0]; // YYYY-MM-DD
      _completed = widget.task!.completed;
    }
  }

  // Function to show Date Picker and set the selected date
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.task?.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.task?.dueDate) {
      setState(() {
        _dueDateController.text =
            picked.toLocal().toString().split(' ')[0]; // YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? '' : ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.task == null ? 'Add a New Task' : 'Edit Task',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 55, 183, 195),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter the description' : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        _selectDueDate(context), // Open date picker on tap
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: 'Due Date (YYYY-MM-DD)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a due date' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Completed"),
                    value: _completed,
                    onChanged: (bool value) {
                      setState(() {
                        _completed = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final task = Task(
                              id: widget.task?.id,
                              title: _titleController.text,
                              description: _descriptionController.text,
                              dueDate: DateTime.parse(_dueDateController.text),
                              completed: _completed,
                            );

                            if (widget.task == null) {
                              await _controller.addTask(task);
                            } else {
                              await _controller.updateTask(
                                  widget.task!.id!, task);
                            }

                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF00796B),
                        ),
                        child: Text(
                          widget.task == null ? 'Add Task' : 'Update Task',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
