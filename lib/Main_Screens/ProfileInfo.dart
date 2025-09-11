// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/UserData.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  UserData? userData;
  bool infoChanged = false;
  bool editMode = false;
  String? imageurl;
  final emailCont = TextEditingController();
  final nameCont = TextEditingController();
  final phoneCont = TextEditingController();
  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false).loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<DataProvider>(context).userData;
    if (!infoChanged) {
      imageurl = userData!.Image;
      emailCont.text = userData!.Email!;
      nameCont.text = userData!.fullName!;
      userData!.Phone != null
          ? phoneCont.text = userData!.Phone.toString()
          : phoneCont.text = '';
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          if (editMode == false) {
            editMode = true;
            setState(() {});
            return;
          }
          if (editMode == true) {
            int? phoneInt;
            String phoneText = phoneCont.text.trim();
            if (phoneText.isNotEmpty && RegExp(r'^\d+$').hasMatch(phoneText)) {
              phoneInt = int.tryParse(phoneText);
            } else {
              phoneInt = null;
            }
            UserData userData = UserData(
              Email: emailCont.text,
              Phone: phoneInt,
              Image: imageurl,
              fullName: nameCont.text,
            );
            bool infoSaved =
                await Provider.of<DataProvider>(context, listen: false)
                    .editAccoutInfo(userData);
            if (infoSaved) {
              setState(() {
                Provider.of<DataProvider>(context, listen: false)
                    .loadUserData();
                editMode = false;
              });
            }
          }
        },
        child: editMode == false
            ? const Icon(Icons.edit)
            : const Icon(Icons.check),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 20, bottom: 20),
                  child: editMode == false
                      ? const Text(
                          'Account Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        )
                      : const Text(
                          'Edit Account Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Image.network(
                    userData!.Image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 20),
              child: TextFormField(
                controller: emailCont,
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 10),
              child: TextFormField(
                controller: nameCont,
                enabled: editMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 10),
              child: TextFormField(
                controller: phoneCont,
                enabled: editMode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  hintText: 'Phone',
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
