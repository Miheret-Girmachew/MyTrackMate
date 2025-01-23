import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<Map<String, dynamic>> _transactions = [];
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _reasonController = TextEditingController();
  String _transactionType = '+';
  int? _editingIndex;
  final _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;


  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }


  Future<void> _loadTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      setState(() {
        _transactions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error loading transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load transactions')));
    }
  }


  Future<void> _saveTransactions() async {
    try {
      await Future.wait(_transactions.asMap().entries.map((entry) async {
        final index = entry.key;
        final transaction = entry.value;
        final docRef = _firestore.collection('users').doc(userId).collection('transactions').doc();
        await docRef.set(transaction);
      }));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transactions saved successfully')));
      
    } catch (e) {
      print("Error saving transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save transactions')));
    }
  }

  Future<void> _addTransaction() async {
      final amount = double.tryParse(_amountController.text);
      final date = _dateController.text;
      final reason = _reasonController.text;

      if (amount != null && date.isNotEmpty && reason.isNotEmpty) {
        Map<String, dynamic> newTransaction = {
              'amount': amount,
              'date': date,
              'reason': reason,
              'type': _transactionType,
        };
        if(_editingIndex == null){
          try {
              final docRef = await _firestore.collection('users').doc(userId).collection('transactions').add(newTransaction);
            setState(() {
                _transactions.add(newTransaction);
             });
                _amountController.clear();
                _dateController.clear();
                _reasonController.clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction added successfully')));

              } catch (e) {
                    print("Error adding transaction: $e");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add transaction')));
                }


        }else{
           try{
             setState(() {
             _transactions[_editingIndex!] = {
              'amount': amount,
              'date': date,
              'reason': reason,
              'type': _transactionType,
            };
           });
           // Update Firestore
              final snapshot = await _firestore.collection('users').doc(userId).collection('transactions').get();
               if (snapshot.docs.isNotEmpty){
                 await _firestore.collection('users').doc(userId).collection('transactions').doc(snapshot.docs[_editingIndex!].id).update(newTransaction);
               }
           _editingIndex = null;
           _amountController.clear();
           _dateController.clear();
           _reasonController.clear();
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction updated successfully')));
           }catch (e){
             print("Error updating transaction: $e");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update transaction')));
           }

        }
        
         _loadTransactions();
    }
  }

  void _editTransaction(int index) {
    setState(() {
      _amountController.text = _transactions[index]['amount'].toString();
      _dateController.text = _transactions[index]['date'];
      _reasonController.text = _transactions[index]['reason'];
      _transactionType = _transactions[index]['type'];
      _editingIndex = index;
    });
  }


   Future<void> _deleteTransaction(int index) async {
      try{
           final snapshot = await _firestore.collection('users').doc(userId).collection('transactions').get();
              if (snapshot.docs.isNotEmpty){
                await _firestore.collection('users').doc(userId).collection('transactions').doc(snapshot.docs[index].id).delete();
                 setState(() {
                _transactions.removeAt(index);
              });
              }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction deleted successfully')));
      } catch (e){
       print("Error deleting transaction: $e");
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete transaction')));
    }
      _loadTransactions();
  }


   Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
      );
      if (picked != null) {
          setState(() {
              _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
          });
      }
   }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
              title: Text(
                  'Transaction Page',
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
                                      controller: _amountController,
                                      decoration: InputDecoration(
                                          labelText: 'Amount',
                                          labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                      SizedBox(height: 20),
                                      Row(
                                          children: [
                                              Expanded(
                                                  child: TextField(
                                                      controller: _dateController,
                                                      decoration: InputDecoration(
                                                          labelText: 'Date',
                                                          labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                                          border: OutlineInputBorder(),
                                                          filled: true,
                                                          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                                      ),
                                                  ),
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
                                                  onPressed: () => _selectDate(context),
                                              ),
                                          ],
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
                                      DropdownButton<String>(
                                          value: _transactionType,
                                          onChanged: (String? newValue) {
                                              setState(() {
                                                _transactionType = newValue!;
                                              });
                                          },
                                          items: <String>['+', '-']
                                              .map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                          }).toList(),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                          onPressed: _addTransaction,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF580645),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                              textStyle: TextStyle(fontSize: 18),
                                          ),
                                          child: Text(_editingIndex == null ? 'Add Transaction' : 'Update Transaction'),
                                      ),
                                      SizedBox(height: 20),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _transactions.length,
                                          itemBuilder: (context, index) {
                                              final transaction = _transactions[index];
                                              return Card(
                                                  elevation: 4,
                                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                                  child: ListTile(
                                                      title: Text('${transaction['type']} ${transaction['amount']}'),
                                                      subtitle: Text('${transaction['date']} - ${transaction['reason']}'),
                                                      trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                              IconButton(
                                                                  icon: Icon(Icons.edit, color: Colors.blue),
                                                                  onPressed: () => _editTransaction(index),
                                                              ),
                                                              IconButton(
                                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                                  onPressed: () => _deleteTransaction(index),
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