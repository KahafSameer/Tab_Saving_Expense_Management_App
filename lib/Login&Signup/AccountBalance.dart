// ignore_for_file: non_constant_identifier_names, file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class AccountBalance {
  int? Balance = 0;
  String? DocId;

  AccountBalance({
    this.Balance,
    this.DocId,
  });
  Map<String, dynamic> toMap() {
    return {
      'Account Balance': Balance,
    };
  }

  factory AccountBalance.fromMap(DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> map = snap.data()!;
    return AccountBalance(
      Balance: map['Account Balance'],
      DocId: snap.id,
    );
  }
}
