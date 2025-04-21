import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_command_todo/custom_button.dart';
import 'package:voice_command_todo/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  final List<TodoModel> _todos = [];
  final SpeechToText _speech = SpeechToText();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  String _voiceInput = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadTodosFromPrefs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _saveTodosToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String result = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todo_list', result);
  }

  Future<void> _loadTodosFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoJson = prefs.getString('todo_list');
    if (todoJson != null) {
      final List decoded = jsonDecode(todoJson);
      setState(() {
        _todos.clear();
        _todos.addAll(decoded.map((item) => TodoModel.fromJson(item)).toList());
      });
    }
  }

  void _addTask(String task) {
    if (task.trim().isEmpty) return;
    setState(() {
      _todos.add(TodoModel(title: task.trim(), isDone: false));
    });
    _saveTodosToPrefs();
  }

  void _addTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: TextFormField(
          controller: _taskController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "Enter Task",
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomElevatedButton(
                onPressed: () {
                  _addTask(_taskController.text);
                  _taskController.clear();
                  Navigator.pop(context);
                },
                text: "Add Task",
              ),
              CustomElevatedButton(
                onPressed: _taskController.clear,
                text: "Clear",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      bool available = await _speech.initialize();
      if (!available) return;

      setState(() => _isListening = true);
      _animationController.repeat();

      _speech.listen(
        onResult: (result) {
          setState(() => _voiceInput = result.recognizedWords);

          if (_voiceInput.toLowerCase().trim().endsWith("stop")) {
            _speech.stop();
            _animationController.stop();
            setState(() => _isListening = false);

            final cleanText =
                _voiceInput.replaceAll(RegExp(r'\bstop\b\$'), '').trim();

            _addTask(cleanText);
            setState(() => _voiceInput = '');
          }
        },
      );

      _speech.statusListener = (status) {
        if (status == "notListening") {
          _animationController.stop();
          setState(() => _isListening = false);
          _saveTodosToPrefs();
        }
      };
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Microphone permission is required to use voice input."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Voice Command To-Do",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) => TodoTile(
                    todo: _todos[index],
                    onToggleDone: () {
                      setState(() {
                        _todos[index].isDone = !_todos[index].isDone;
                      });
                      _saveTodosToPrefs();
                    },
                    onDelete: () {
                      setState(() => _todos.removeAt(index));
                      _saveTodosToPrefs();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _addTaskDialog,
            shape: const CircleBorder(),
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 10),
          ScaleTransition(
            scale: _isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
            child: FloatingActionButton(
              onPressed: _startListening,
              shape: const CircleBorder(),
              child: const Icon(Icons.mic),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggleDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: IconButton(
        icon: Icon(todo.isDone ? Icons.check_circle_outlined : Icons.circle_outlined),
        onPressed: onToggleDone,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.clear_outlined),
        onPressed: onDelete,
      ),
    );
  }
}
