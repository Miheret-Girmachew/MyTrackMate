import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String userId, String groupId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> addTask(String userId, String groupId, Task task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toFirestore());
  }

  Future<void> updateTask(String userId, String groupId, String taskId, Task task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update(task.toFirestore());
  }

  Future<void> deleteTask(String userId, String groupId, String taskId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('taskGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  String generateTaskId() {
    return _db.collection('tasks').doc().id;
  }
}
