import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';

class SpendingBarChart extends StatefulWidget {
  const SpendingBarChart({super.key});

  @override
  State<SpendingBarChart> createState() => _SpendingBarChartState();
}

class _SpendingBarChartState extends State<SpendingBarChart> {
  DateTime? _startDate;
  DateTime? _endDate;
  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context, listen: false).loadTransactionHistory();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<DataProvider>(context).transactionHistory;

    final filteredTxs = transactions.where((tx) {
      final txDate = DateTime.parse(tx.date!);
      return txDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          txDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();

    double totalWithdrawn = 0;
    double totalDeposited = 0;
    Map<String, double> categorySpending = {};

    for (var tx in filteredTxs) {
      final amount = tx.amount?.toDouble() ?? 0;
      final category = _getCategoryForTransaction(tx.title);
      if (tx.type == 'Added') {
        totalDeposited += amount;
        categorySpending['Deposited'] =
            (categorySpending['Deposited'] ?? 0) + amount;
      } else if (tx.type == 'Withdrawn') {
        totalWithdrawn += amount;
        // Always add to Withdrawn category for summary and chart
        categorySpending['Withdrawn'] =
            (categorySpending['Withdrawn'] ?? 0) + amount;
        // Also add to specific category if not generic Withdrawn
        if (category != 'Withdrawn') {
          categorySpending[category] =
              (categorySpending[category] ?? 0) + amount;
        }
      }
    }

    final double netBalance = totalDeposited - totalWithdrawn;
    final int withdrawnCount =
        filteredTxs.where((tx) => tx.type == 'Withdrawn').length;
    final double avgSpending =
        withdrawnCount > 0 ? totalWithdrawn / withdrawnCount : 0.0;

    final List<PieChartSectionData> pieChartSections =
        categorySpending.entries.where((entry) => entry.value > 0).map((entry) {
      final color = _getColorForCategory(entry.key);
      final textColor = entry.key == 'Deposited' ? Colors.black : Colors.white;
      // Add border for Deposited section for visibility if only Deposited exists
      final showBorder =
          entry.key == 'Deposited' && categorySpending.length == 1;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title:
            '${(entry.value / (totalWithdrawn + totalDeposited) * 100).toStringAsFixed(1)}%',
        radius: 54,
        titleStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        borderSide: showBorder
            ? BorderSide(color: Colors.black, width: 2)
            : BorderSide.none,
      );
    }).toList();

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 20,
          ),
          child: Card(
            margin: const EdgeInsets.fromLTRB(30, 16, 30, 16),
            elevation: 12,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  _startDate == null
                                      ? 'Start Date'
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  _endDate == null
                                      ? 'End Date'
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_startDate != null || _endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear Dates',
                          onPressed: () {
                            setState(() {
                              _startDate = DateTime.now()
                                  .subtract(const Duration(days: 30));
                              _endDate = DateTime.now();
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Card
                  Card(
                    color: Colors.blue[50],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(
                              'Withdrawn', totalWithdrawn, Colors.red),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Deposited', totalDeposited,
                              _getColorForCategory('Deposited')),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                              'Net Balance', netBalance, Colors.deepPurple),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  // Pie Chart
                  if (pieChartSections.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 8),
                      child: SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            sectionsSpace: 10,
                            centerSpaceRadius: 40,
                            pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback: (event, response) {
                                if (response != null &&
                                    response.touchedSection != null) {
                                  final idx = response
                                      .touchedSection!.touchedSectionIndex;
                                  final section = pieChartSections[idx];
                                  final category =
                                      categorySpending.keys.toList()[idx];
                                  final amount = categorySpending[category];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '$category: Rs ${amount?.toStringAsFixed(0)}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          swapAnimationDuration:
                              const Duration(milliseconds: 800),
                          swapAnimationCurve: Curves.easeOutExpo,
                        ),
                      ),
                    )
                  else
                    const Center(child: Text('No data for selected period')),

                  const SizedBox(height: 20),
                  Card(
                    color: Colors.blue[50],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: categorySpending.keys
                              .where(
                                  (category) => categorySpending[category]! > 0)
                              .map((category) => _buildLegend(
                                  category,
                                  _getColorForCategory(category),
                                  categorySpending[category] ?? 0))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryForTransaction(String? title) {
    if (title == null) return 'Withdrawn';
    final fixedExpenses = [
      'Rent',
      'Tuition Fees',
      'Electricity Bill',
      'Internet Bill',
      'Grocery',
      'Insurance',
      'Mobile Recharge',
    ];
    if (fixedExpenses.contains(title)) {
      return title;
    }
    if (title == 'Fixed Expenses') {
      return 'Other Fixed Expenses';
    }
    return 'Withdrawn';
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Deposited':
        return Colors.green;
      case 'Rent':
        return Colors.blue;
      case 'Tuition Fees':
        return Colors.purple;
      case 'Electricity Bill':
        return Colors.orange;
      case 'Internet Bill':
        return Colors.teal;
      case 'Grocery':
        return Colors.pink;
      case 'Insurance':
        return Colors.amber;
      case 'Mobile Recharge':
        return Colors.cyan;
      case 'Other Fixed Expenses':
        return Colors.brown;
      case 'Withdrawn':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        Text('Rs ${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLegend(String name, Color color, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$name: Rs ${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
