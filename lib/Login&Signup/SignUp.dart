// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously, body_might_complete_normally_nullable, non_constant_identifier_names, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savings/Login&Signup/AccountBalance.dart';
import 'package:savings/Login&Signup/Login.dart';
import 'package:savings/Login&Signup/VerifyEmail.dart';
import 'package:savings/UserData.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showPassword = true;
  final Formkey = GlobalKey<FormState>();
  final nameCont = TextEditingController();
  final emailCont = TextEditingController();
  final phoneNumberCont = TextEditingController();
  final passwordCont = TextEditingController();
  File? _image;

  Future pickimage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        _image = imageTemp;
      });
    } on PlatformException catch (e) {
      print('Can not pick image :' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 4, 65, 203),
      body: Form(
        key: Formkey,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: 200,
              child: Image.asset('assets/logo-no-background.png'),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 100),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: nameCont,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Name is missing';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'UserName',
                                fillColor: Color.fromARGB(87, 4, 64, 203),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: emailCont,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Email is missing';
                                } else if (!value.contains('@gmail.com')) {
                                  return 'invalid Email';
                                } else if (value.length <= 11) {
                                  return 'invalid Email';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Email',
                                fillColor: Color.fromARGB(87, 4, 64, 203),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: phoneNumberCont,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Phone number is missing';
                                } else if (!value.contains('+')) {
                                  return 'Phone Number must start with country';
                                } else if (value.length <= 10 ||
                                    value.length >= 16) {
                                  return 'Invalid Phone Number';
                                } else if (value.contains(RegExp(r'[A-Z]')) ||
                                    value.contains(RegExp(r'[a-z]'))) {
                                  return 'Invalid Phone Number';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Phone Number',
                                fillColor: Color.fromARGB(87, 4, 64, 203),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: passwordCont,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Password id required';
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Password',
                                fillColor: Color.fromARGB(87, 4, 64, 203),
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (showPassword == false) {
                                      showPassword = true;
                                    } else {
                                      showPassword = false;
                                    }
                                    setState(() {});
                                  },
                                  icon: showPassword != true
                                      ? Icon(
                                          Icons.remove_red_eye_rounded,
                                          color: Colors.blue,
                                        )
                                      : Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                        ),
                                ),
                                prefixIcon: Icon(
                                  Icons.password,
                                  color: Colors.white,
                                ),
                              ),
                              obscureText: showPassword,
                            ),
                          ),
                          SizedBox(height: 50),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Color.fromARGB(255, 19, 61, 156);
                                      } else if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey;
                                      }
                                      return Color.fromARGB(255, 4, 65, 203);
                                    },
                                  ),
                                ),
                                onPressed: () async {
                                  if (_image == null) {
                                    Fluttertoast.showToast(
                                        msg: 'Pick an image!');
                                    return;
                                  }
                                  if (Formkey.currentState!.validate()) {
                                    try {
                                      final task = await FirebaseStorage
                                          .instance
                                          .ref('Users')
                                          .child(
                                              DateTime.now().toIso8601String())
                                          .putFile(_image!);
                                      String url =
                                          await task.ref.getDownloadURL();
                                      UserData userData = UserData(
                                        Image: url,
                                        fullName: nameCont.text,
                                        Email: emailCont.text,
                                        Phone: int.parse(phoneNumberCont.text),
                                      );

                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: emailCont.text,
                                              password: passwordCont.text)
                                          .then((value) {
                                        FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(value.user?.uid)
                                            .set(userData.toMap());
                                        AccountBalance accountBalance =
                                            AccountBalance(Balance: 0);
                                        FirebaseFirestore.instance
                                            .collection('Account Balance')
                                            .doc(value.user?.uid)
                                            .set(accountBalance.toMap());
                                      });
                                      print('Success');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerifyEmail(),
                                        ),
                                      );
                                    } catch (e) {
                                      print('Failed: ' + e.toString());
                                    }
                                  }
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    top: -30,
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          shape: const OutlineInputBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Divider(
                                        thickness: 5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        pickimage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                      leading: Icon(Icons.camera),
                                      title: Text('Camera'),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        pickimage(ImageSource.gallery);

                                        Navigator.pop(context);
                                      },
                                      leading: Icon(Icons.image),
                                      title: Text('Gallery'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: _image == null
                          ? SizedBox(
                              height: 120,
                              width: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 4, 123, 203),
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                    size: 120,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 120,
                              width: 120,
                              child: ClipOval(
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
