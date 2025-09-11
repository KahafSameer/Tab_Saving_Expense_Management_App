// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionHistory>? transactionHistory = [];
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    //loading the history
    Provider.of<DataProvider>(context, listen: false).loadTransactionHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //assigning the history the transactionHistory object
    transactionHistory = Provider.of<DataProvider>(context).transactionHistory;
    //showing CircularProgressIndicator if data is not loaded
    if (transactionHistory == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }
    //main scaffold body
    List<TransactionHistory> filteredHistory = transactionHistory!.where((tx) {
      final query = _searchQuery.toLowerCase();
      bool matchesSearch = tx.title!.toLowerCase().contains(query) ||
          tx.type!.toLowerCase().contains(query) ||
          tx.amount.toString().contains(query);
      bool matchesDate = true;
      if (_startDate != null) {
        DateTime txDate = DateTime.parse(tx.date!);
        matchesDate = matchesDate && !txDate.isBefore(_startDate!);
      }
      if (_endDate != null) {
        DateTime txDate = DateTime.parse(tx.date!);
        matchesDate = matchesDate && !txDate.isAfter(_endDate!);
      }
      return matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                _startDate == null
                                    ? 'Start Date'
                                    : DateFormat('MMM d, yyyy')
                                        .format(_startDate!),
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _endDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                _endDate == null
                                    ? 'End Date'
                                    : DateFormat('MMM d, yyyy')
                                        .format(_endDate!),
                                style: TextStyle(fontWeight: FontWeight.w500),
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
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          filteredHistory.isEmpty
              ? Expanded(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text('No records found',
                          style: TextStyle(fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          await Provider.of<DataProvider>(context,
                                  listen: false)
                              .loadTransactionHistory();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                    )
                  ],
                ))
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<DataProvider>(context, listen: false)
                          .loadTransactionHistory();
                    },
                    child: ListView.builder(
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        filteredHistory.sort(
                          (b, a) {
                            return a.date!.compareTo(b.date!);
                          },
                        );
                        String formattedDateTime =
                            DateFormat('MMM d, yyyy hh:mm a').format(
                                DateTime.parse(filteredHistory[index].date!));
                        bool isAdded = filteredHistory[index].type! == 'Added';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAdded
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                child: Icon(
                                  isAdded
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isAdded ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    'PKR ${filteredHistory[index].amount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          isAdded ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAdded ? 'Deposit' : 'Withdraw',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredHistory[index].title.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        formattedDateTime,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // trailing: Text(formattedDateTime),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
