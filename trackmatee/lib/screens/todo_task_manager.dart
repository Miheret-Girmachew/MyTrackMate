import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/task_group_card.dart'; 
import '../models/task.dart' as modelTask; 

class TodoTaskManager extends StatefulWidget {
  @override
  _TodoTaskManagerState createState() => _TodoTaskManagerState();
}

class _TodoTaskManagerState extends State<TodoTaskManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTaskGroup(String name) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final taskGroup = {
      'name': name,
      'progress': 0.0,
      'taskCount': 0,
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .add(taskGroup);
  }

  Future<void> editTaskGroup(String groupId, String newName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId)
        .update({'name': newName});
  }

  Future<void> deleteTaskGroup(String groupId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final taskGroupRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId);

    final tasksSnapshot = await taskGroupRef.collection('tasks').get();
    for (var task in tasksSnapshot.docs) {
      await task.reference.delete();
    }

    await taskGroupRef.delete();
  }

  Future<void> updateGroupData(String groupId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final taskGroupRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId);

    final tasksSnapshot = await taskGroupRef.collection('tasks').get();
    final tasks = tasksSnapshot.docs;

    final activeTasks = tasks.where((task) =>
        task['status'] == 'Undone' || task['status'] == 'In Progress').length;

    final totalTasks = tasks.length;
    final doneTasks = tasks.where((task) => task['status'] == 'Done').length;
    final progress = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    await taskGroupRef.update({
      'taskCount': activeTasks,
      'progress': progress,
    });
  }

  void showInputDialog({required Function(String) onSubmit, String initialText = ''}) {
    TextEditingController controller = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialText.isEmpty ? 'Add Task Group' : 'Edit Task Group'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter task group name',
              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSubmit(controller.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Task group name cannot be empty'),
                  ));
                }
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
                foregroundColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Center(child: Text('Please log in to see your task groups.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo Task Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Roboto',
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Color(0xFF580645),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('taskGroups')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No task groups found.');
                }

                final taskGroups = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: taskGroups.length,
                  itemBuilder: (context, index) {
                    final group = taskGroups[index];
                    final groupId = group.id;
                    final groupData = group.data() as Map<String, dynamic>;

                    return TaskGroupCard(
                      groupName: groupData['name'],
                      groupId: groupId,
                      taskCount: groupData['taskCount'] ?? 0,
                      progress: groupData['progress'] ?? 0.0,
                      color: Colors.orange,
                      onEdit: () {
                        showInputDialog(
                          initialText: groupData['name'],
                          onSubmit: (newName) => editTaskGroup(groupId, newName),
                        );
                      },
                      onDelete: () => deleteTaskGroup(groupId),
                      onUpdate: () => updateGroupData(groupId), 
                      onTasksUpdated: (updatedTasks) {
                        updateGroupData(groupId); 
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showInputDialog(onSubmit: addTaskGroup);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
      ),
    );
  }
}
