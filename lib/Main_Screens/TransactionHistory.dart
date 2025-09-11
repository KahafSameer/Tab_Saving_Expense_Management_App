// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistory {
  int? amount;
  String? title;
  String? date;
  String? type;
  String? userId;
  String? docId;
  TransactionHistory({
    this.amount,
    this.title,
    this.date,
    this.type,
    this.userId,
    this.docId,
  });
  Map<String, dynamic> toMap() {
    return {
      'Amount': amount,
      'Title': title,
      'Date': date,
      'Type': type,
      'UserId': userId,
    };
  }

  factory TransactionHistory.fromMap(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> map = snap.data()!;
    return TransactionHistory(
      amount: map['Amount'],
      title: map['Title'],
      date: map['Date'],
      type: map['Type'],
      userId: map['UserId'],
      docId: snap.id,
    );
  }
}
