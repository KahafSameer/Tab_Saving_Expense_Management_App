// ignore_for_file: file_names, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savings/DataProvider.dart';
import 'package:savings/Main_Screens/Items.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final fkey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  File? _image;
  //this function is used to pick the image for new goal
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
      backgroundColor: Color.fromARGB(255, 23, 61, 156),
      body: Form(
        key: fkey,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                    image: AssetImage('assets/bgDesign.png'),
                    opacity: 100,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add New Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set a new savings target and track your progress!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 75,
                        top: -75,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(24),
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
                                          borderRadius:
                                              BorderRadius.circular(20)),
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
                                            leading: Icon(Icons.camera,
                                                color: Colors.blue),
                                            title: Text('Camera'),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              pickimage(ImageSource.gallery);
                                              Navigator.pop(context);
                                            },
                                            leading: Icon(Icons.image,
                                                color: Colors.blue),
                                            title: Text('Gallery'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Image.file(_image!,
                                            fit: BoxFit.cover)),
                                  )
                                : Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.blue[100],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.blue[700],
                                        size: 40,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 80),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 8),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: titleController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Title is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        hintText: 'Title',
                                        prefixIcon: Icon(Icons.flag,
                                            color: Colors.blue),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 14),
                                    TextFormField(
                                      controller: amountController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Amount is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        hintText: 'Amount',
                                        prefixIcon: Icon(Icons.attach_money,
                                            color: Colors.blue),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    SizedBox(height: 14),
                                    TextFormField(
                                      controller: _dateController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Date is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: 'Target Date',
                                        prefixIcon: Icon(Icons.calendar_today,
                                            color: Colors.blue),
                                      ),
                                      keyboardType: TextInputType.none,
                                      onTap: () async {
                                        DateTime date = DateTime.now();
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: date,
                                          firstDate: DateTime(date.year - 100),
                                          lastDate: DateTime(date.year + 100),
                                        );
                                        if (picked != null && picked != date) {
                                          setState(() {
                                            _dateController.text =
                                                DateFormat('MM/dd/yyyy')
                                                    .format(picked);
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: Icon(Icons.add_circle_outline,
                                            color: Colors.white),
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text('Add Goal',
                                              style: TextStyle(fontSize: 18)),
                                        ),
                                        onPressed: () async {
                                          if (fkey.currentState!.validate()) {
                                            DateTime currentDate =
                                                DateTime.now();
                                            DateTime selectedDate =
                                                DateFormat('MM/dd/yyyy').parse(
                                                    _dateController.text);
                                            if (selectedDate
                                                    .isBefore(currentDate) ||
                                                selectedDate.isAtSameMomentAs(
                                                    currentDate)) {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Please enter a valid Date',
                                                textColor: Colors.white,
                                                backgroundColor: Colors.blue,
                                              );
                                              return;
                                            }
                                            if (int.parse(
                                                    amountController.text) >
                                                10000000) {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Sorry the maximum limit is 10 million',
                                                textColor: Colors.white,
                                                backgroundColor: Colors.blue,
                                              );
                                              return;
                                            }
                                            Fluttertoast.showToast(
                                                msg: 'Please Wait',
                                                backgroundColor:
                                                    Colors.deepPurple);
                                            String? url;
                                            if (_image != null) {
                                              final extension =
                                                  _image!.path.split('.').last;
                                              final fileName =
                                                  '${DateTime.now().toIso8601String().replaceAll(":", "-")}.$extension';
                                              final metadata = SettableMetadata(
                                                  contentType:
                                                      'image/$extension');
                                              final task = await FirebaseStorage
                                                  .instance
                                                  .ref('Items')
                                                  .child(fileName)
                                                  .putFile(_image!, metadata);
                                              url = await task.ref
                                                  .getDownloadURL();
                                            }
                                            Items items = Items(
                                              Image: url,
                                              Title: titleController.text,
                                              TargetAmount: int.parse(
                                                  amountController.text),
                                              TargetDate: _dateController.text,
                                              CurrentAmount: 0,
                                              uid: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                            );
                                            bool itemAdded =
                                                await Provider.of<DataProvider>(
                                                        context,
                                                        listen: false)
                                                    .addItem(items);
                                            if (itemAdded) {
                                              titleController.text = '';
                                              amountController.text = '';
                                              _dateController.text = '';
                                              Fluttertoast.showToast(
                                                  msg: 'Success',
                                                  backgroundColor:
                                                      Colors.deepPurple);
                                              setState(() {});
                                            }
                                            if (!itemAdded) {
                                              Fluttertoast.showToast(
                                                  msg: 'An error occured',
                                                  backgroundColor:
                                                      Colors.deepPurple);
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.blue),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(16)),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                  color: Colors.blue[200]!),
                                            ),
                                          ),
                                          elevation:
                                              MaterialStateProperty.all<double>(
                                                  3),
                                        ),
                                      ),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
