// ignore_for_file: file_names, prefer_interpolation_to_compose_strings, avoid_print, unused_local_variable, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:savings/Login&Signup/AccountBalance.dart';
import 'package:savings/Main_Screens/Items.dart';
import 'package:savings/Main_Screens/GoalsHistory.dart';
import 'package:savings/Main_Screens/TransactionHistory.dart';
import 'package:savings/UserData.dart';
import 'package:savings/repository/ChatBotRepo.dart';
import 'package:savings/repository/textGenModel.dart';

class DataProvider extends ChangeNotifier {
  void addChat(TextGenModel chat) {
    chats.add(chat);
    notifyListeners();
  }

  void clearChats() {
    chats.clear();
    notifyListeners();
  }

  List<TextGenModel> chats = [];

  sendChat(BuildContext context, TextGenModel chat) async {
    chats.add(chat);

    await GigaChatRepo.textGenRepo(context, chats);

    notifyListeners();
  }

  //is used to login user form google
  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        print('Login canceled by user');
        return false;
      }
// to outhenticate and login with Google
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
//for firebase to send retrive data
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final currentUser = userCredential.user;

      UserData userData = UserData(
        Image: currentUser!.photoURL,
        Email: currentUser.email,
        fullName: currentUser.displayName,
      );
      //
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      if (userDataSnapshot.exists) {
        UserData userData = UserData.fromMap(userDataSnapshot.data()!);
        UserData newData = UserData(
          Email: userData.Email,
          Image: userData.Image,
          Phone: userData.Phone,
          fullName: userData.fullName,
        );
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .set(newData.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .set(userData.toMap());
      }

      final accountBalanceSnapshot = await FirebaseFirestore.instance
          .collection('Account Balance')
          .doc(currentUser.uid)
          .get();

      if (accountBalanceSnapshot.exists) {
        AccountBalance currentBalance =
            AccountBalance.fromMap(accountBalanceSnapshot);
        AccountBalance newBalance = AccountBalance(
          Balance: currentBalance.Balance,
        );
        await FirebaseFirestore.instance
            .collection('Account Balance')
            .doc(currentUser.uid)
            .set(newBalance.toMap());
      } else {
        AccountBalance newBalance = AccountBalance(
          Balance: 0,
        );
        await FirebaseFirestore.instance
            .collection('Account Balance')
            .doc(currentUser.uid)
            .set(newBalance.toMap());
      }

      notifyListeners();
      print('Success');
      return true;
    } catch (e, stackTrace) {
      print('Failed: $e');
      print(stackTrace);
      return false;
    }
  }

  Future<bool> editAccoutInfo(UserData userData) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.uid)
          .update(userData.toMap());
      notifyListeners();
      print('Success');
      return true;
    } catch (e) {
      print('Failed: $e');
      return false;
    }
  }

  List<Items> item = [];

  Future<bool> addItem(Items items) async {
    try {
      item.add(items);
      await FirebaseFirestore.instance.collection('Items').add(items.toMap());
      notifyListeners();
      print('Success');
      return true;
    } catch (e) {
      print('Failed: ' + e.toString());
      return false;
    }
  }

  loadData() async {
    try {
      await FirebaseFirestore.instance
          .collection('Items')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        item = List.generate(
          value.size,
          (index) => Items.fromMap(value.docs[index]),
        );
        notifyListeners();
      });
      print('Success');
    } catch (e) {
      print('Failed: ' + e.toString());
    }
  }

  updateItem(Items item) async {
    try {
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(item.DocId)
          .update(item.toMap());
      notifyListeners();
      print('Success');
    } catch (e) {
      print('Failed: ' + e.toString());
    }
  }

  List<GoalsHistory> goalsHistory = [];
  loadHistory(String? docid) async {
    try {
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(docid)
          .collection('Transactions')
          .get()
          .then((value) {
        goalsHistory = List.generate(
            value.size, (index) => GoalsHistory.fromMap(value.docs[index]));
        notifyListeners();
      });
      print('Success');
    } catch (e) {
      print('Failed: ' + e.toString());
    }
  }

  updateData(Items item, String? docid, GoalsHistory transactionHistory) async {
    try {
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(docid)
          .update(item.toMap())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('Items')
            .doc(docid)
            .collection('Transactions')
            .doc()
            .set(transactionHistory.toMap());
      });
      notifyListeners();

      print('Success');
    } catch (e) {
      print('Failed:' + e.toString());
    }
  }

  changeAccountBalance(AccountBalance accountBalance, String? docid) async {
    try {
      await FirebaseFirestore.instance
          .collection('Account Balance')
          .doc(docid)
          .update(accountBalance.toMap());
      notifyListeners();

      print('Success');
    } catch (e) {
      print('Failed:' + e.toString());
    }
  }

  Future<bool> updateAccountBalance(AccountBalance accountBalance,
      TransactionHistory transactionHistory) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Account Balance')
          .doc(currentUser!.uid)
          .update(accountBalance.toMap());
      await FirebaseFirestore.instance
          .collection('Transaction History')
          .doc()
          .set(transactionHistory.toMap());
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to update Account Balance: ' + e.toString());
      return false;
    }
  }

  List<TransactionHistory> transactionHistory = [];
  loadTransactionHistory() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('Transaction History')
          .where('UserId', isEqualTo: currentUser.uid)
          .get()
          .then((value) {
        transactionHistory = List.generate(value.size,
            (index) => TransactionHistory.fromMap(value.docs[index]));
      });
      notifyListeners();
    } catch (e) {
      print('Failed to load transaction history: ' + e.toString());
    }
  }

  UserData? userData;

  loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> value) {
        userData = UserData.fromMap(value.data()!);
        notifyListeners();
      });
    } catch (e) {
      print('Failed:' + e.toString());
    }
  }

  AccountBalance? accountBalance;

  Future<void> loadAccountBalance() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('Account Balance')
          .doc(currentUser?.uid)
          .get()
          .then((value) {
        accountBalance = AccountBalance.fromMap(value);
        notifyListeners();
      });
    } catch (e) {
      print('Failed:' + e.toString());
    }
  }

  Future<bool> deleteItem(
      String? docId,
      AccountBalance accountBalance,
      String? image,
      List<GoalsHistory>? transactionHistory,
      TransactionHistory? newtransaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (image != null) {
        final ref = FirebaseStorage.instance.refFromURL(image);
        ref.delete();
      }

      if (transactionHistory!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Items')
            .doc(docId)
            .collection('Transactions')
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });
      }

      if (newtransaction != null) {
        await FirebaseFirestore.instance
            .collection('Transaction History')
            .doc()
            .set(newtransaction.toMap());
      }
      await FirebaseFirestore.instance
          .collection('Items')
          .doc(docId)
          .delete()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('Account Balance')
            .doc(user!.uid)
            .set(accountBalance.toMap())
            .then((value) {});
      });
      notifyListeners();
      print('Success');
      return true;
    } catch (e) {
      print('Failed: $e');
      return false;
    }
  }

  Future<void> deductAmount(
      double amount, TransactionHistory transactionHistory) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && accountBalance != null) {
        accountBalance!.Balance = (accountBalance!.Balance! - amount).toInt();
        await FirebaseFirestore.instance
            .collection('Account Balance')
            .doc(currentUser.uid)
            .set(accountBalance!.toMap())
            .then(
              (value) => FirebaseFirestore.instance
                  .collection('Transaction History')
                  .add(
                    transactionHistory.toMap(),
                  ),
            );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to deduct amount: $e');
    }
  }
}
