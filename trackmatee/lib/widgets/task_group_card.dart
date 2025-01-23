import 'package:flutter/material.dart';
import '../screens/TaskGroupDetailPage.dart';
import '../models/task.dart'; 

class TaskGroupCard extends StatelessWidget {
  final String groupName;
  final String groupId;
  final int taskCount;
  final double progress;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdate; 
  final Function(List<Task>) onTasksUpdated;

  TaskGroupCard({
    required this.groupName,
    required this.groupId,
    required this.taskCount,
    required this.progress,
    required this.color,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
    required this.onTasksUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskGroupDetailPage(
              groupName: groupName,
              groupId: groupId,
              onTasksUpdated: onTasksUpdated,
            ),
          ),
        );

        onUpdate();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: const Icon(Icons.work, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    '$taskCount Tasks (Active)', 
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Progress: ${(progress * 100).toInt()}%', 
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
