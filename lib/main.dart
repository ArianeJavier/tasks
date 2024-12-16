import 'package:flutter/material.dart';
import 'views/task_list_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ydeqaxlrvwjnnlrxftbi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkZXFheGxydndqbm5scnhmdGJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM2NjcyMzksImV4cCI6MjA0OTI0MzIzOX0.NGeWiH-B6GYiHr1MtZUV9KiDgNtsFZvvYe4rPDn0Q34',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListView(),
    );
  }
}
