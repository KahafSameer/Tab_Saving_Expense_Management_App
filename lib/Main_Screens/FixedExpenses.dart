import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  Icon _getExpenseIcon(String expense) {
    switch (expense) {
      case 'Rent':
        return const Icon(Icons.home, color: Colors.blue);
      case 'Tuition Fees':
        return const Icon(Icons.school, color: Colors.blue);
      case 'Electricity Bill':
        return const Icon(Icons.flash_on, color: Colors.blue);
      case 'Internet Bill':
        return const Icon(Icons.wifi, color: Colors.blue);
      case 'Grocery':
        return const Icon(Icons.shopping_cart, color: Colors.blue);
      case 'Insurance':
        return const Icon(Icons.shield, color: Colors.blue);
      case 'Mobile Recharge':
        return const Icon(Icons.phone_android, color: Colors.blue);
      default:
        return const Icon(Icons.attach_money, color: Colors.blue);
    }
  }

  double _totalSelectedDeduction = 0;

  void _updateTotalDeduction() {
    double total = 0;
    _selectedExpenses.forEach((expense, isSelected) {
      if (isSelected) {
        final amount =
            double.tryParse(_amountControllers[expense]?.text ?? '') ?? 0;
        total += amount;
      }
    });
    setState(() {
      _totalSelectedDeduction = total;
    });
  }

  final List<String> _expenses = [
    'Rent',
    'Tuition Fees',
    'Electricity Bill',
    'Internet Bill',
    'Grocery',
    'Insurance',
    'Mobile Recharge',
  ];

  final Map<String, bool> _selectedExpenses = {};
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void initState() {
    super.initState();
    for (var expense in _expenses) {
      _selectedExpenses[expense] = false;
      _amountControllers[expense] = TextEditingController();
      _amountControllers[expense]!.addListener(_updateTotalDeduction);
    }
    // Initial total
    _updateTotalDeduction();
  }

  @override
  void dispose() {
    for (var controller in _amountControllers.values) {
      controller.removeListener(_updateTotalDeduction);
      controller.dispose();
    }
    super.dispose();
  }

  void _onOkPressed() {
    double totalDeduction = 0;
    _selectedExpenses.forEach((expense, isSelected) {
      if (isSelected) {
        final amount = double.tryParse(_amountControllers[expense]!.text) ?? 0;
        totalDeduction += amount;
      }
    });
    TransactionHistory transactionHistory = TransactionHistory(
      amount: totalDeduction.toInt(),
      date: DateTime.now().toString(),
      title: 'Fixed Expenses',
      type: 'Withdrawn',
      userId: FirebaseAuth.instance.currentUser!.uid,
    );

    if (totalDeduction > 0) {
      Provider.of<DataProvider>(context, listen: false)
          .deductAmount(totalDeduction, transactionHistory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '₨$totalDeduction deducted from main balance.',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Fixed Monthly Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 4,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return ListView(
              padding: EdgeInsets.only(bottom: bottomInset + 32),
              physics: const BouncingScrollPhysics(),
              children: [
                // Total Deduction Card
                Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.savings, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Total Deduction: ₨${_totalSelectedDeduction.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Expense List
                ..._expenses.map((expense) => Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: CheckboxListTile(
                            title: Text(expense),
                            value: _selectedExpenses[expense],
                            onChanged: (value) {
                              setState(() {
                                _selectedExpenses[expense] = value!;
                              });
                              _updateTotalDeduction();
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            secondary: _getExpenseIcon(expense),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: _selectedExpenses[expense] == true
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: TextField(
                                    controller: _amountControllers[expense],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      labelText: 'Amount for $expense',
                                      prefixIcon: const Icon(Icons.money),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (_) => _updateTotalDeduction(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    )),
                // Bottom Button (full width)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onOkPressed,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Deduct & Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ),
                // Extra space for keyboard
                const SizedBox(height: 180),
              ],
            );
          },
        ),
      ),
    );
  }
}
