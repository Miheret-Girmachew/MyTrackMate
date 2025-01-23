import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskGroupDetailPage extends StatefulWidget {
  final String groupName;
  final String groupId;
  final Function(List<Task>) onTasksUpdated;

  TaskGroupDetailPage({
    required this.groupName,
    required this.groupId,
    required this.onTasksUpdated,
  });

  @override
  _TaskGroupDetailPageState createState() => _TaskGroupDetailPageState();
}

class _TaskGroupDetailPageState extends State<TaskGroupDetailPage> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TaskService _taskService = TaskService();
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('User is not authenticated');
    }
  }

  // Add a new task to the Firestore database
  void addTask() async {
    if (taskController.text.isNotEmpty && timeController.text.isNotEmpty) {
      Task newTask = Task(
        id: _taskService.generateTaskId(),
        name: taskController.text.trim(),
        status: 'Undone',
        time: timeController.text.trim(),
        groupId: widget.groupId,
      );
      await _taskService.addTask(userId, widget.groupId, newTask);
      taskController.clear();
      timeController.clear();
      _updateTasks();
    }
  }

  // Edit an existing task
  void editTask(String taskId, Task task) async {
    taskController.text = task.name;
    timeController.text = task.time;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Task updatedTask = Task(
                  id: task.id,
                  name: taskController.text.trim(),
                  status: task.status,
                  time: timeController.text.trim(),
                  groupId: task.groupId,
                );
                await _taskService.updateTask(userId, widget.groupId, taskId, updatedTask);
                taskController.clear();
                timeController.clear();
                Navigator.pop(context);
                _updateTasks();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete a task from Firestore
  void deleteTask(String taskId) async {
    await _taskService.deleteTask(userId, widget.groupId, taskId);
    _updateTasks();
  }

  // Updates the task list and task group metadata (task count and progress)
  void _updateTasks() async {
    List<Task> tasks = await _taskService.getTasks(userId, widget.groupId).first;

    // Calculate active tasks (Undone + In Progress)
    int activeTasks = tasks.where((task) =>
        task.status == 'Undone' || task.status == 'In Progress').length;

    // Calculate progress as Done tasks percentage
    int totalTasks = tasks.length;
    int doneTasks = tasks.where((task) => task.status == 'Done').length;
    double progress = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    // Notify parent widget about updated tasks
    widget.onTasksUpdated(tasks);

    // Update Firestore with new task count and progress
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(widget.groupId)
        .update({
      'taskCount': activeTasks,
      'progress': progress,
    });
  }

  // Render tasks by their status
  Widget taskList(String status, Color color) {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(userId, widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<Task> filteredTasks =
            snapshot.data?.where((task) => task.status == status).toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$status Tasks:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            ...filteredTasks.map((task) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.task, color: color),
                  title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time: ${task.time}'),
                      DropdownButton<String>(
                        value: task.status,
                        onChanged: (newStatus) async {
                          if (newStatus != null) {
                            Task updatedTask = Task(
                              id: task.id,
                              name: task.name,
                              status: newStatus,
                              time: task.time,
                              groupId: task.groupId,
                            );
                            await _taskService.updateTask(
                                userId, widget.groupId, task.id, updatedTask);
                            _updateTasks();
                          }
                        },
                        items: ['Undone', 'In Progress', 'Done']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editTask(task.id, task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: Text(
    '${widget.groupName} Tasks',
    style: const TextStyle(
      color: Colors.white,
    ),
  ),
  backgroundColor: const Color(0xFF580645),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              taskList('Undone', Colors.red),
              const SizedBox(height: 20),
              taskList('In Progress', Colors.blue),
              const SizedBox(height: 20),
              taskList('Done', Colors.green),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Time'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: addTask,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
