// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, use_build_context_synchronously, sort_child_properties_last, depend_on_referenced_packages, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Login&Signup/AccountBalance.dart';
import 'package:savings/Main_Screens/Detail.dart';
import 'package:savings/Main_Screens/Items.dart';
import 'package:savings/Main_Screens/NewItem.dart';
import 'package:intl/intl.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';
import 'package:savings/UserData.dart';
import '../Login&Signup/Login.dart';
import 'package:savings/Main_Screens/ProfileInfo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //custom navigator for bottom nav bar
  void pushReplacementWithoutNavBar(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  String? selectedDropDownItem = 'by name';
  List<Items> _items = [];
  bool loading = false;
  final fkey = GlobalKey<FormState>();
  final addAmountCont = TextEditingController();
  final addTitleCont = TextEditingController();
  final withAmountCont = TextEditingController();
  final withTitleCont = TextEditingController();
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];
  UserData? userData;
  AccountBalance? accountBalance;

  @override
  void initState() {
    //loading the data from provider inside initState
    Provider.of<DataProvider>(context, listen: false).loadUserData();
    Provider.of<DataProvider>(context, listen: false).loadAccountBalance();
    Provider.of<DataProvider>(context, listen: false).loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Assigning data to objects or list of objects after loading
    _items = Provider.of<DataProvider>(context, listen: true).item;
    userData = Provider.of<DataProvider>(context).userData;
    accountBalance = Provider.of<DataProvider>(context).accountBalance;
    //showing the circular progress indicator if data is not loaded
    if (accountBalance == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }
    //same
    if (userData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }
    //main scaffold
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 4, 65, 203),
      body: Column(
        children: [
          Expanded(
            flex: 2,
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
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileInfo(),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _items.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 30, right: 5),
                                  child: Container(
                                    height: 30,
                                    width: 155,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      //sorting data
                                      child: DropdownButton<String>(
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        underline: SizedBox(),
                                        borderRadius: BorderRadius.circular(20),
                                        dropdownColor: Colors.white,
                                        value: selectedDropDownItem,
                                        items: [
                                          DropdownMenuItem(
                                            child: Text('  Sort by Name'),
                                            value: 'by name',
                                          ),
                                          DropdownMenuItem(
                                            child: Text('  Sort by Date'),
                                            value: 'by date',
                                          ),
                                          DropdownMenuItem(
                                            child: Text('  Sort by Amount'),
                                            value: 'by amount',
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(
                                            () {
                                              selectedDropDownItem = value;
                                              if (value == 'by name') {
                                                _items.sort((a, b) => a.Title!
                                                    .compareTo(b.Title!));
                                              }
                                              if (value == 'by amount') {
                                                _items.sort((b, a) =>
                                                    a.CurrentAmount!.compareTo(
                                                        b.CurrentAmount!));
                                              }
                                              if (value == 'by date') {
                                                _items.sort((b, a) => a
                                                    .TargetDate!
                                                    .compareTo(b.TargetDate!));
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(width: 5),
                          Padding(
                            padding: const EdgeInsets.only(top: 30, right: 15),
                            child: PopupMenuButton<int>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              itemBuilder: (context) => [
                                //additional reload and logout button
                                PopupMenuItem(
                                  child: Text('Reload'),
                                  value: 2,
                                ),
                                PopupMenuItem(
                                  child: Text('Log Out'),
                                  value: 3,
                                ),
                              ],
                              child: Icon(
                                Icons.pending,
                                color: Colors.white,
                                size: 35,
                              ),
                              onSelected: (value) {
                                //on data reload
                                if (value == 2) {
                                  setState(() {
                                    Provider.of<DataProvider>(context,
                                            listen: false)
                                        .loadData();
                                    Provider.of<DataProvider>(context,
                                            listen: false)
                                        .loadAccountBalance();
                                  });
                                }
                                //on log out
                                if (value == 3) {
                                  GoogleSignIn().signOut();
                                  FirebaseAuth.instance.signOut();
                                  //custom navigator as i mentioned on the top it will navigate to the login page without the bottom nav bar
                                  pushReplacementWithoutNavBar(
                                      context, LoginPage());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              r'PKR ' + accountBalance!.Balance.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Total account Balance',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //this row contains aad money or withdraw money buttons
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  //showing bottom sheet if add money button pressed
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) =>
                                        DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      maxChildSize: 0.7,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Form(
                                            key: fkey,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 20,
                                                        top: 20,
                                                      ),
                                                      child: Text(
                                                        'Add Money',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 30),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: TextFormField(
                                                    controller: addTitleCont,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Title is required';
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Colors.grey[200],
                                                      hintText: 'Title',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
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
                                                      fillColor:
                                                          Colors.grey[200],
                                                      hintText: 'Amount',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                ElevatedButton(
                                                  //add money button with some calculations
                                                  onPressed: () async {
                                                    if (loading == false) {
                                                      if (fkey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        if (int.parse(
                                                                addAmountCont
                                                                    .text) >
                                                            10000000) {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                'Sorry the maximum limit is 10 million',
                                                            textColor:
                                                                Colors.white,
                                                            backgroundColor:
                                                                Colors.blue,
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                          loading = false;
                                                          setState(() {});
                                                          return;
                                                        }
                                                        int currentBalance =
                                                            accountBalance!
                                                                .Balance!;
                                                        AccountBalance
                                                            newBalance =
                                                            AccountBalance(
                                                          Balance: currentBalance +
                                                              int.parse(
                                                                  addAmountCont
                                                                      .text),
                                                        );
                                                        TransactionHistory
                                                            transactionHistory =
                                                            TransactionHistory(
                                                          amount: int.parse(
                                                              addAmountCont
                                                                  .text),
                                                          date: DateTime.now()
                                                              .toString(),
                                                          title:
                                                              addTitleCont.text,
                                                          type: 'Added',
                                                          userId: FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                        );
                                                        bool balanceUpdated = await Provider
                                                                .of<DataProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .updateAccountBalance(
                                                                newBalance,
                                                                transactionHistory);
                                                        if (balanceUpdated) {
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          await Provider.of<
                                                                      DataProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .loadAccountBalance();
                                                          addTitleCont.text =
                                                              '';
                                                          addAmountCont.text =
                                                              '';
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                        } else if (!balanceUpdated) {
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'An error occured',
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              textColor:
                                                                  Colors.white);
                                                        }
                                                      }
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                      Color.fromARGB(
                                                          255, 23, 61, 156),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets.all(
                                                                    16)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        side: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                  child: loading == false
                                                      ? Text('Add')
                                                      : CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.green,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(
                                        'Add Money',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  //showing bottom sheet if withdraw money button pressed
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) =>
                                        DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      maxChildSize: 0.7,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Form(
                                            key: fkey,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 20,
                                                        top: 20,
                                                      ),
                                                      child: Text(
                                                        'Withdraw Money',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 30),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: TextFormField(
                                                    controller: withTitleCont,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Title is required';
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Colors.grey[200],
                                                      hintText: 'Title',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
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
                                                      fillColor:
                                                          Colors.grey[200],
                                                      hintText: 'Amount',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                ElevatedButton(
                                                  //withdraw money button with some calculations
                                                  onPressed: () async {
                                                    if (loading == false) {
                                                      if (fkey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        int currentBalance =
                                                            accountBalance!
                                                                .Balance!;
                                                        int newBalance =
                                                            currentBalance -
                                                                int.parse(
                                                                    withAmountCont
                                                                        .text);
                                                        if (newBalance < 0) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'You have insufficient money',
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              textColor:
                                                                  Colors.white);
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          return;
                                                        }
                                                        AccountBalance
                                                            updetedBalance =
                                                            AccountBalance(
                                                          Balance: newBalance,
                                                        );
                                                        TransactionHistory
                                                            transactionHistory =
                                                            TransactionHistory(
                                                          amount: int.parse(
                                                              withAmountCont
                                                                  .text),
                                                          date: DateTime.now()
                                                              .toString(),
                                                          title: withTitleCont
                                                              .text,
                                                          type: 'Withdrawn',
                                                          userId: FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                        );
                                                        bool balanceUpdated = await Provider
                                                                .of<DataProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                            .updateAccountBalance(
                                                                updetedBalance,
                                                                transactionHistory);
                                                        if (balanceUpdated) {
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          await Provider.of<
                                                                      DataProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .loadAccountBalance();
                                                          withTitleCont.text =
                                                              '';
                                                          withAmountCont.text =
                                                              '';
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                        } else if (!balanceUpdated) {
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  'An error occured',
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              textColor:
                                                                  Colors.white);
                                                        }
                                                      }
                                                    }
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                      Color.fromARGB(
                                                          255, 23, 61, 156),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets.all(
                                                                    16)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        side: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                  ),
                                                  child: loading == false
                                                      ? Text('Withdraw')
                                                      : CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.red,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: Text(
                                        'Withdraw Money',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Goals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Text('No goals has been set'),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Provider.of<DataProvider>(context,
                                      listen: false)
                                  .loadData();
                              setState(() {});
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                var targetAmount = _items[index].TargetAmount;
                                var currentAmount = _items[index].CurrentAmount;
                                var percent =
                                    currentAmount! / targetAmount! * 100;
                                String dateString = _items[index].TargetDate!;
                                DateTime endDate =
                                    DateFormat('MM/dd/yyyy').parse(dateString);
                                DateTime now = DateTime.now();
                                Duration difference = endDate.difference(now);
                                int daysLeft = difference.inDays;
                                DateTime currentDate = DateTime.now();
                                DateTime targetDate = DateFormat('MM/dd/yyyy')
                                    .parse(_items[index].TargetDate!);
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                          item: _items[index],
                                          accountBalance: accountBalance!,
                                          color: colors[index % colors.length],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _items[index].Image != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    _items[index]
                                                        .Image
                                                        .toString(),
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: colors[index %
                                                              colors.length],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            _items[index]
                                                                .Title!
                                                                .substring(0, 2)
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    color: colors[
                                                        index % colors.length],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      _items[index]
                                                          .Title!
                                                          .substring(0, 2)
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _items[index].Title!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    _items[index].TargetAmount ==
                                                            _items[index]
                                                                .CurrentAmount
                                                        ? Text('Completed',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                        : currentDate.isAfter(
                                                                    targetDate) ||
                                                                currentDate.isAtSameMomentAs(
                                                                    targetDate)
                                                            ? Text('Time over',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                            : Text(
                                                                '$daysLeft Days Left',
                                                                style: TextStyle(
                                                                    color: Colors.blue)),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                LinearPercentIndicator(
                                                  percent: percent / 100,
                                                  progressColor: colors[index],
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  lineHeight: 8,
                                                  barRadius: Radius.circular(8),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                r'PKR ' +
                                                    _items[index]
                                                        .CurrentAmount
                                                        .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF1741A0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
