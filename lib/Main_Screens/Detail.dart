// ignore_for_file: file_names, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, must_be_immutable, unnecessary_string_interpolations, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Login&Signup/AccountBalance.dart';
import 'package:savings/Main_Screens/BottomNavBar.dart';
import 'package:savings/Main_Screens/HomePage.dart';
import 'package:savings/Main_Screens/Items.dart';
import 'package:savings/Main_Screens/GoalsHistory.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';

class DetailPage extends StatefulWidget {
  //Data coming from previous page
  Items item;
  AccountBalance accountBalance;
  Color color;
  DetailPage({
    Key? key,
    required this.item,
    required this.accountBalance,
    required this.color,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final fkey = GlobalKey<FormState>();
  final TextEditingController addAmountCont = TextEditingController();
  final TextEditingController withAmountCont = TextEditingController();
  bool targetDateOver = false;
  bool targetComplete = false;
  late var currentAmount;
  late var targetAmount;
  late var percent;
  late var yourTarget;
  late String dateString;
  late DateTime endDate;
  late DateTime now;
  late Duration difference;
  late int daysLeft;
  late DateTime date;
  late DateFormat dateFormate;
  late String formattedDate;
  late DateTime targetDate;
  late DateTime currentDate;
  bool isDialogShown = false;
  List<GoalsHistory> _transactionHistory = [];
  final dateController = TextEditingController();
  @override
  void initState() {
    //some calculations inside init state
    currentAmount = widget.item.CurrentAmount;
    targetAmount = widget.item.TargetAmount;
    percent = currentAmount / targetAmount * 100;
    yourTarget = (currentAmount / targetAmount * 100).toInt();

    dateString = widget.item.TargetDate!;
    endDate = DateFormat('MM/dd/yyyy').parse(dateString);
    now = DateTime.now();
    difference = endDate.difference(now);
    daysLeft = difference.inDays;
    date = endDate;

    dateFormate = DateFormat('dMMMMyyyy');
    formattedDate = dateFormate.format(date);

    Provider.of<DataProvider>(context, listen: false)
        .loadHistory(widget.item.DocId);
    currentDate = DateTime.now();
    targetDate = DateFormat('MM/dd/yyyy').parse(widget.item.TargetDate!);
    //Showing the dialog if target is completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item.TargetAmount == widget.item.CurrentAmount) {
        targetComplete = true;
        Future.delayed(Duration(milliseconds: 100)).then((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  '✔ Target copmlete',
                  style: TextStyle(color: Colors.green),
                ),
                content: Text(
                    'Congratulations your target has been successfully completed'),
                actions: [
                  TextButton(
                    child: Text(
                      'ok',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
      }
    });
    //Showing the dialog if target is incomplete and targeted date is gone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentDate.isAfter(targetDate) ||
          currentDate.isAtSameMomentAs(targetDate)) {
        targetDateOver = true;
        Future.delayed(Duration(milliseconds: 100)).then((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Targeted time over'),
                content: Text('Do you want to extend the target date?'),
                actions: [
                  TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      //showing the date expantion dialog if user want to extend the target date
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Enter New Date'),
                            content: TextField(
                              controller: dateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'New Date',
                              ),
                              keyboardType: TextInputType.datetime,
                              onTap: () async {
                                DateTime date = DateTime.now();

                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(date.year - 100),
                                  lastDate: DateTime(date.year + 100),
                                );

                                if (picked != null && picked != date) {
                                  setState(() {
                                    dateController.text =
                                        DateFormat('MM/dd/yyyy').format(picked);
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  //expanding date with some error handling
                                  if (dateController.text.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Please enter the new date first',
                                      textColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                    );
                                    return;
                                  } else {
                                    DateTime selectedDate =
                                        DateFormat('MM/dd/yyyy')
                                            .parse(dateController.text);
                                    if (selectedDate.isBefore(currentDate) ||
                                        selectedDate
                                            .isAtSameMomentAs(currentDate)) {
                                      Fluttertoast.showToast(
                                        msg: 'Please enter a valid Date',
                                        textColor: Colors.white,
                                        backgroundColor: Colors.blue,
                                      );
                                      return;
                                    }
                                    Items item = Items(
                                      CurrentAmount: widget.item.CurrentAmount,
                                      Image: widget.item.Image,
                                      TargetAmount: widget.item.TargetAmount,
                                      TargetDate: dateController.text,
                                      Title: widget.item.Title,
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      DocId: widget.item.DocId,
                                    );
                                    await Provider.of<DataProvider>(context,
                                            listen: false)
                                        .updateItem(item);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BottomNavBar(),
                                      ),
                                      (route) => false,
                                    );
                                    Fluttertoast.showToast(
                                      msg: 'Date extended',
                                      textColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                    );
                                  }
                                },
                                child: Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _transactionHistory = Provider.of<DataProvider>(context).goalsHistory;
    //Main body of detail page
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Wrap(
        children: [
          //This row contains 2 floating action buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Color.fromARGB(255, 23, 61, 156),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    onPressed: () {
                      //opening the bottom sheet to add money in a goal
                      if (targetDateOver) {
                        Fluttertoast.showToast(
                          msg: 'Target date is Over',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      if (targetComplete) {
                        Fluttertoast.showToast(
                          msg: 'Target is complete',
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      //aad money bottom sheet
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.5,
                          maxChildSize: 0.6,
                          expand: false,
                          builder: (context, scrollController) {
                            return SingleChildScrollView(
                              controller: scrollController,
                              child: Form(
                                key: fkey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 60),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: addAmountCont,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Amount is required';
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          hintText: 'Amount',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        //add money button with some calculations error handling
                                        if (fkey.currentState!.validate()) {
                                          int newBalance =
                                              widget.accountBalance.Balance! -
                                                  int.parse(addAmountCont.text);
                                          int newAmount =
                                              widget.item.CurrentAmount! +
                                                  int.parse(addAmountCont.text);
                                          if (newBalance < 0) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'You Have insufficient money in your Account',
                                              backgroundColor: Colors.blue,
                                              textColor: Colors.white,
                                            );
                                            addAmountCont.text = '';

                                            Navigator.pop(context);
                                            return;
                                          }
                                          if (newAmount >
                                              widget.item.TargetAmount!) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'You can not exceed the tergeted amount',
                                              backgroundColor: Colors.blue,
                                              textColor: Colors.white,
                                            );
                                            addAmountCont.text = '';

                                            Navigator.pop(context);
                                            return;
                                          }

                                          AccountBalance accountBalance =
                                              AccountBalance(
                                            Balance: newBalance,
                                          );
                                          Items item = Items(
                                            CurrentAmount: newAmount,
                                            Image: widget.item.Image,
                                            TargetAmount:
                                                widget.item.TargetAmount,
                                            TargetDate: widget.item.TargetDate,
                                            Title: widget.item.Title,
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                          GoalsHistory goalsHistory =
                                              GoalsHistory(
                                                  Amount: addAmountCont.text,
                                                  Date: DateTime.now(),
                                                  Type: 'Added');
                                          TransactionHistory
                                              transactionHistory =
                                              TransactionHistory(
                                            amount:
                                                int.parse(addAmountCont.text),
                                            date: DateTime.now().toString(),
                                            title: 'Added to Goal ' +
                                                widget.item.Title.toString(),
                                            type: 'Withdrawn',
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .updateData(
                                                  item,
                                                  widget.item.DocId,
                                                  goalsHistory);
                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .updateAccountBalance(
                                            accountBalance,
                                            transactionHistory,
                                          );

                                          await Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage(),
                                              ));
                                          Fluttertoast.showToast(
                                            msg: 'Successfully Added',
                                            backgroundColor: Colors.deepPurple,
                                          );
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 23, 61, 156),
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(16)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side:
                                                BorderSide(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                      child: Text('Add'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Text('💰 Add Money'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Color.fromARGB(255, 23, 61, 156),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    onPressed: () {
                      //opening the bottom sheet to withdraw money from a goal
                      if (targetDateOver) {
                        Fluttertoast.showToast(
                          msg: 'Target date is Over',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      if (targetComplete) {
                        Fluttertoast.showToast(
                          msg: 'Target is complete',
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      //withdraw money bottom sheet
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.5,
                          maxChildSize: 0.6,
                          expand: false,
                          builder: (context, scrollController) {
                            return SingleChildScrollView(
                              controller: scrollController,
                              child: Form(
                                key: fkey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 60),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: withAmountCont,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Amount is required';
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          hintText: 'Amount',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      //withdraw money button with some calculations error handling
                                      onPressed: () async {
                                        if (fkey.currentState!.validate()) {
                                          int newBalance = widget
                                                  .accountBalance.Balance! +
                                              int.parse(withAmountCont.text);
                                          int newAmount = widget
                                                  .item.CurrentAmount! -
                                              int.parse(withAmountCont.text);
                                          if (newAmount < 0) {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'You do not have that much much money to withdraw from this item',
                                              backgroundColor: Colors.blue,
                                              textColor: Colors.white,
                                            );
                                            withAmountCont.text = '';

                                            Navigator.pop(context);
                                            return;
                                          }

                                          AccountBalance accountBalance =
                                              AccountBalance(
                                            Balance: newBalance,
                                          );
                                          Items item = Items(
                                            CurrentAmount: widget
                                                    .item.CurrentAmount! -
                                                int.parse(withAmountCont.text),
                                            Image: widget.item.Image,
                                            TargetAmount:
                                                widget.item.TargetAmount,
                                            TargetDate: widget.item.TargetDate,
                                            Title: widget.item.Title,
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                          GoalsHistory goalsHistory =
                                              GoalsHistory(
                                                  Amount: withAmountCont.text,
                                                  Date: DateTime.now(),
                                                  Type: 'Withdrawn');
                                          TransactionHistory
                                              transactionHistory =
                                              TransactionHistory(
                                            amount:
                                                int.parse(withAmountCont.text),
                                            date: DateTime.now().toString(),
                                            title: 'Withdrawn from Goal ' +
                                                widget.item.Title.toString(),
                                            type: 'Added',
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          );
                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .updateData(
                                                  item,
                                                  widget.item.DocId,
                                                  goalsHistory);
                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .updateAccountBalance(
                                            accountBalance,
                                            transactionHistory,
                                          );

                                          await Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage(),
                                              ));
                                          Fluttertoast.showToast(
                                            msg: 'Successfully Withdrawn',
                                            backgroundColor: Colors.deepPurple,
                                          );
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 23, 61, 156),
                                        ),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.all(16)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side:
                                                BorderSide(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                      child: Text('Withdraw'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Text('💸 Withdraw'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 4, 65, 203),
      //main body column
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 4, 65, 203),
                image: DecorationImage(
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  image: AssetImage('assets/bgDesign.png'),
                  opacity: 100,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, left: 15),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                      //PopUp Menu button containing delete button
                      Padding(
                        padding: const EdgeInsets.only(top: 30, right: 15),
                        child: PopupMenuButton<int>(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 1,
                            ),
                          ],
                          child: Icon(
                            Icons.pending,
                            color: Colors.white,
                            size: 35,
                          ),
                          onSelected: (value) async {
                            //delete button with some calculations
                            TransactionHistory? transactionHistory;
                            if (value == 1) {
                              int newBalance;
                              if (widget.item.CurrentAmount ==
                                  widget.item.TargetAmount) {
                                newBalance = widget.accountBalance.Balance!;
                              } else {
                                newBalance = widget.accountBalance.Balance! +
                                    widget.item.CurrentAmount!;
                                transactionHistory = TransactionHistory(
                                  amount: widget.item.CurrentAmount,
                                  date: DateTime.now().toString(),
                                  title:
                                      'Money returned from deleted goal ${widget.item.Title}',
                                  type: 'Added',
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                );
                              }
                              AccountBalance accountBalance = AccountBalance(
                                Balance: newBalance,
                              );
                              bool itemDeleted =
                                  await Provider.of<DataProvider>(context,
                                          listen: false)
                                      .deleteItem(
                                          widget.item.DocId,
                                          accountBalance,
                                          widget.item.Image,
                                          _transactionHistory,
                                          transactionHistory);
                              if (itemDeleted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: MediaQuery.of(context).size.width / 2 - 67.5,
                    top: -67.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.item.Image != null
                          ? SizedBox(
                              height: 130,
                              width: 130,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    widget.item.Image.toString(),
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          color: widget.color,
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.item.Title!
                                                .substring(0, 2)
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 67.5,
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                    },
                                  )))
                          : Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                color: widget.color,
                              ),
                              child: Center(
                                child: Text(
                                  widget.item.Title!
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 67.5,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 70,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            r'PKR ' + widget.item.CurrentAmount.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.item.Title!,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.item.CurrentAmount ==
                                    widget.item.TargetAmount
                                ? Text(
                                    'Completed',
                                    style: TextStyle(color: Colors.green),
                                  )
                                : currentDate.isAfter(targetDate) ||
                                        currentDate.isAtSameMomentAs(targetDate)
                                    ? Text('Time over')
                                    : Text(
                                        '$daysLeft Days Left',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                            Text(
                              '$formattedDate',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearPercentIndicator(
                          percent: percent / 100,
                          progressColor: widget.color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '🎯 Your Target',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '($yourTarget%)',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              r'PKR ' '$targetAmount',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 20,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              ' Saving History',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        //this list shows the saving history of a goal
                        child: ListView.builder(
                          itemCount: _transactionHistory.length,
                          itemBuilder: (context, index) {
                            String formattedHistoryDate =
                                DateFormat('EEEE, dMMMyyyy')
                                    .format(_transactionHistory[index].Date!);
                            _transactionHistory
                                .sort((b, a) => a.Date!.compareTo(b.Date!));
                            return ListTile(
                              trailing: Text(
                                r'PKR ' + _transactionHistory[index].Amount!,
                                style: TextStyle(),
                              ),
                              leading: Icon(Icons.history),
                              title: Text(
                                _transactionHistory[index].Type!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(formattedHistoryDate.toString()),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
