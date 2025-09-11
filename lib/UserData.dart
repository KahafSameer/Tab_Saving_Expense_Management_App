// ignore_for_file: non_constant_identifier_names, file_names, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
//model class is used to store data in forebase . every small component has its own firebase, send and retrive data from FB in a shape
class UserData {
  String? Image;
  String? fullName;
  String? Email;
  int? Phone;
  String? DocId;
  UserData({
    this.Image,
    this.fullName,
    this.Email,
    this.Phone,
    this.DocId,
  });
//format or map used to send data in firebase 
  Map<String, dynamic> toMap() {
    return {
      'Image': Image,
      'Full Name': fullName,
      'Email': Email,
      'Phone': Phone,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      Image: map['Image'],
      fullName: map['Full Name'],
      Email: map['Email'],
      Phone: map['Phone'],
    );
  }
}
