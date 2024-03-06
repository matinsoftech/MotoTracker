// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/data/screens/home/home_screen.dart';

import '../listscreen.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final ImagePicker imgpicker = ImagePicker();
  SharedPreferences? _prefs;

  preferenceFunction() async {
    _prefs = await SharedPreferences.getInstance();
    licensefilePaths = _prefs!.getStringList("license");
    expiryDate = _prefs!.getString("expiry license");

    setState(() {});
  }

  List<XFile>? licensefiles;

  List<String>? licensefilePaths;
  String? expiryDate;

  Future<void> _selectExpiryDate(
      BuildContext context, String uploadType) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      if (uploadType.startsWith("l")) {
        setState(() {
          expiryDate = picked.toString();
          _prefs!.setString("expiry $uploadType", expiryDate!);
        });
      }
    }
  }

  @override
  void initState() {
    preferenceFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        title: const Text('Upload Document'),
        backgroundColor: HomeScreen.primaryDark,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              uploadBox('license', onTap: () async {
                try {
                  List<XFile>? pickedfiles = await imgpicker.pickMultiImage();

                  if (pickedfiles != []) {
                    licensefiles = pickedfiles;
                    licensefilePaths =
                        licensefiles!.map((e) => e.path).toList();
                    _prefs?.setStringList("license", licensefilePaths!);
                    setState(() {});
                  }
                } catch (_) {}
              }),
            ],
          ),
        ),
      ),
    );
  }

  uploadBox(uploadtype, {required VoidCallback onTap}) {
    List<String>? filePaths = _prefs?.getStringList(uploadtype);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: HomeScreen.primaryDark,
                  spreadRadius: 1,
                  blurRadius: 0.2),
            ],
            // color: HomeScreen.primaryDark,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Upload your $uploadtype',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'arial_font',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: onTap,
                    child: const Icon(
                      CupertinoIcons.cloud_upload,
                      color: Colors.blue,
                    ))
              ],
            ),
            const Text(
              'PNG, JPG and JPEG files are allowed',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 8,
                fontFamily: 'arial_font',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pick Expiry Date :  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    fontFamily: 'arial_font',
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    _selectExpiryDate(context, uploadtype);
                  },
                  child: Text('${expiryDate ?? 'choose'} '),
                ),
              ],
            ),
            filePaths != null && filePaths.isNotEmpty
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: filePaths.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: Image.file(
                                              File(filePaths[index]),
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        },
                                        context: context);
                                  },
                                  child: Image.file(
                                    height: 200,
                                    width: 160,
                                    File(filePaths[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: (() async {
                                        showDeleteDialog(context, index,
                                            filePaths, uploadtype);
                                      }),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.red,
                                      ),
                                    ))
                              ],
                            ),
                          );
                        }),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context, int index, List<String> filePaths,
      String uploadtype) {
    return showDialog(
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Image?"),
            content: const Text("Are you sure, you want to delete the image?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("No, don't delete")),
              ElevatedButton(
                onPressed: () async {
                  filePaths.removeAt(index);
                  await _prefs!.setStringList(uploadtype, filePaths);
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Yes, delete image"),
              )
            ],
          );
        },
        context: context);
  }
}
