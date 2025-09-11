// ignore_for_file: file_names, non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  String? Image;
  String? Title;

  String? TargetDate;

  int? CurrentAmount = 0;
  int? TargetAmount;

  String? DocId;
  String? uid;

  Items({
    this.Image,
    this.Title,
    this.TargetDate,
    this.CurrentAmount,
    this.TargetAmount,
    this.DocId,
    this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': Image,
      'title': Title,
      'targetDate': TargetDate,
      'currentAmount': CurrentAmount,
      'targetAmount': TargetAmount,
      'uid': uid,
    };
  }

  factory Items.fromMap(DocumentSnapshot<Map<String, dynamic>> snap) {
    Map<String, dynamic> map = snap.data()!;
    return Items(
      Image: map['image'],
      Title: map['title'],
      TargetDate: map['targetDate'],
      CurrentAmount: map['currentAmount'],
      TargetAmount: map['targetAmount'],
      DocId: snap.id,
    );
  }
}
