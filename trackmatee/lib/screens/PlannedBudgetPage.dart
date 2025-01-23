import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PlannedBudgetPage extends StatefulWidget {
  @override
  _PlannedBudgetPageState createState() => _PlannedBudgetPageState();
}

class _PlannedBudgetPageState extends State<PlannedBudgetPage> {
  List<Map<String, dynamic>> _plannedBudgets = []; 
  final _countController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dueDateController = TextEditingController();
  int? _editingIndex;
  final _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadPlannedBudgets();
  }

  @override
  void dispose() {
    _countController.dispose();
    _reasonController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _loadPlannedBudgets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('plannedBudgets')
          .get();
      setState(() {
        _plannedBudgets = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error loading planned budgets: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load planned budgets')));
    }
  }

  Future<void> _savePlannedBudgets() async {
    try {
      await Future.wait(_plannedBudgets.asMap().entries.map((entry) async {
        final index = entry.key;
        final plannedBudget = entry.value;
        final docRef =
            _firestore.collection('users').doc(userId).collection('plannedBudgets').doc();
        await docRef.set(plannedBudget);
      }));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Planned budgets saved successfully')));
    } catch (e) {
      print("Error saving planned budgets: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save planned budgets')));
    }
  }

  Future<void> _addPlannedBudget() async {
    final count = int.tryParse(_countController.text);
    final reason = _reasonController.text;
    final dueDate = _dueDateController.text;

    if (count != null && reason.isNotEmpty && dueDate.isNotEmpty) {
      Map<String, dynamic> newPlannedBudget = {
        'count': count,
        'reason': reason,
        'dueDate': dueDate,
      };
      if (_editingIndex == null) {
        try {
          final docRef = await _firestore
              .collection('users')
              .doc(userId)
              .collection('plannedBudgets')
              .add(newPlannedBudget);
          setState(() {
            _plannedBudgets.add(newPlannedBudget);
          });
          _countController.clear();
          _reasonController.clear();
          _dueDateController.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Planned budget added successfully')));
        } catch (e) {
          print("Error adding planned budget: $e");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add planned budget')));
        }
      } else {
        try {
          setState(() {
            _plannedBudgets[_editingIndex!] = {
              'count': count,
              'reason': reason,
              'dueDate': dueDate,
            };
          });

          final snapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('plannedBudgets')
              .get();
          if (snapshot.docs.isNotEmpty) {
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('plannedBudgets')
                .doc(snapshot.docs[_editingIndex!].id)
                .update(newPlannedBudget);
          }

          _editingIndex = null;
          _countController.clear();
          _reasonController.clear();
          _dueDateController.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Planned budget updated successfully')));
        } catch (e) {
          print("Error updating planned budget: $e");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to update planned budget')));
        }
      }
      _loadPlannedBudgets();
    }
  }

  void _editPlannedBudget(int index) {
    setState(() {
      _countController.text = _plannedBudgets[index]['count'].toString();
      _reasonController.text = _plannedBudgets[index]['reason'];
      _dueDateController.text = _plannedBudgets[index]['dueDate'];
      _editingIndex = index;
    });
  }

  Future<void> _deletePlannedBudget(int index) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('plannedBudgets')
          .get();
      if (snapshot.docs.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('plannedBudgets')
            .doc(snapshot.docs[index].id)
            .delete();
        setState(() {
          _plannedBudgets.removeAt(index);
        });
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Planned budget deleted successfully')));
    } catch (e) {
      print("Error deleting planned budget: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete planned budget')));
    }
    _loadPlannedBudgets();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Planned Budget',
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
                    TextField(
                      controller: _countController,
                      decoration: InputDecoration(
                        labelText: 'Sample Number (Count)',
                        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dueDateController,
                            decoration: InputDecoration(
                              labelText: 'Due Date',
                              labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
                          onPressed: () => _selectDueDate(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addPlannedBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF580645),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text(_editingIndex == null ? 'Add Planned Budget' : 'Update Planned Budget'),
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _plannedBudgets.length,
                      itemBuilder: (context, index) {
                        final plannedBudget = _plannedBudgets[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('${plannedBudget['count']} - ${plannedBudget['reason']}'),
                            subtitle: Text('Due Date: ${plannedBudget['dueDate']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editPlannedBudget(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePlannedBudget(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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