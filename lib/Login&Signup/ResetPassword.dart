// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously, prefer_const_constructors, non_constant_identifier_names, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    final emailCont = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 4, 65, 203),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            width: 200,
            child: Image.asset('assets/logo-no-background.png'),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
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
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 4, 65, 203),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: emailCont,
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
                                if (states.contains(MaterialState.pressed)) {
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
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                      email: emailCont.text);
                              Fluttertoast.showToast(
                                  msg: 'An email has beed sent',
                                  textColor: Colors.white,
                                  backgroundColor:
                                      Color.fromARGB(255, 4, 65, 203),
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT);
                              Navigator.pop(context);
                            } catch (e) {
                              print('Failed: ' + e.toString());
                            }
                          },
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
