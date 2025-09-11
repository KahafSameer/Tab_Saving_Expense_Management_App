// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Login&Signup/SignIn.dart';
import 'package:savings/Login&Signup/SignUp.dart';
import 'package:savings/Main_Screens/BottomNavBar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool buttonPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 65, 203),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            width: 200,
            child: Image.asset('assets/logo-no-background.png'),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Image.asset('assets/bgDesign.png'),
            ),
          ),
          Column(
            children: [
              Text(
                'Reach your goals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'effortlessly',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 270,
                  height: 55,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Color.fromARGB(255, 19, 61, 156);
                          } else if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return Color.fromARGB(255, 19, 61, 156);
                        },
                      ),
                    ),
                    onPressed: () async {
                      if (!buttonPressed) {
                        setState(() {
                          buttonPressed = true;
                        });
                        bool loggedIn = await Provider.of<DataProvider>(context,
                                listen: false)
                            .loginWithGoogle();
                        if (loggedIn) {
                          setState(() {
                            buttonPressed = false;
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavBar(),
                            ),
                          );
                        }
                        if (!loggedIn) {
                          setState(() {
                            buttonPressed = false;
                          });
                          Fluttertoast.showToast(
                            msg: 'An error Occured',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                          );
                        }
                      }
                    },
                    child: buttonPressed == false
                        ? ListTile(
                            leading: Logo(Logos.google),
                            title: Text(
                              'Sign in with Google',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListTile(
                            leading: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            title: Text(
                              'Please wait',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => SignUpPage(),
                  //       ),
                  //     );
                  //   },
                  //   child: Text(
                  //     'Create an Account',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                  // Text(
                  //   'or',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => SignInPage(),
                  //       ),
                  //     );
                  //   },
                  //   child: Text(
                  //     'Login',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 50,
                  child: Column(
                    children: [
                      Text(
                        "By continuing you agree to TabSaving's",
                        style: TextStyle(color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "Terms of Service",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            " and ",
                            style: TextStyle(color: Colors.white),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
