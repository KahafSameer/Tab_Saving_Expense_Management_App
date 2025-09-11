// ignore_for_file: non_constant_identifier_names, file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class GoalsHistory {
  String? Amount;
  DateTime? Date;
  String? Type;
  GoalsHistory({this.Amount, this.Date, this.Type});

  Map<String, dynamic> toMap() {
    return {
      'amount': Amount,
      'date': Date,
      'type': Type,
    };
  }

  factory GoalsHistory.fromMap(DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> map = snap.data()!;
    return GoalsHistory(
      Amount: map['amount'],
      Date: map['date'].toDate(),
      Type: map['type'],
    );
  }
}
