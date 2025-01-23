import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String taskName;

  TaskCard({required this.taskName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.task,
              color: isDarkMode ? Theme.of(context).iconTheme.color : Colors.blue, 
            ),
            SizedBox(width: 12),
            Text(
              taskName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Theme.of(context).textTheme.bodyLarge?.color : Colors.black, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}