import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_task_manager.dart';
import 'budget_tracker.dart';
import '../widgets/custom_button.dart';
import '../main.dart'; 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TrackMate',
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
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).getTheme() == ThemeData.dark()
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.white,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to TrackMate!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TodoTaskManager()),
                        );
                      },
                      text: '📝 Task Manager',
                      backgroundColor: isDarkMode ? Theme.of(context).buttonTheme.colorScheme?.primary : Color(0xFF854488),
                      textColor: isDarkMode ? Theme.of(context).buttonTheme.colorScheme?.onPrimary : Colors.white,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BudgetTracker()),
                        );
                      },
                      text: '💰 Budget Tracker',
                      backgroundColor: isDarkMode ? Theme.of(context).buttonTheme.colorScheme?.primary : Colors.white,
                      textColor: isDarkMode ? Theme.of(context).buttonTheme.colorScheme?.onPrimary : Color(0xFF1E108A),
                      borderColor: isDarkMode ? Theme.of(context).buttonTheme.colorScheme?.primary : Color(0xFF1E108A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}