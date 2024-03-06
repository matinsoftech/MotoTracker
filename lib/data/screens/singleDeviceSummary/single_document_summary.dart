// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

class SingleDocumentScreen extends StatefulWidget {
  const SingleDocumentScreen({super.key});

  @override
  State<SingleDocumentScreen> createState() => _SingleDocumentScreenState();
}

class _SingleDocumentScreenState extends State<SingleDocumentScreen> {
  final ImagePicker imgpicker = ImagePicker();
  SharedPreferences? _prefs;
  // DateTime _expiryDate = DateTime.now();

  preferenceFunction() async {
    _prefs = await SharedPreferences.getInstance();
    // licensefilePaths = _prefs!.getStringList("license");
    // _prefs!.setStringList("blue book ${StaticVarMethod.deviceId}", []);
    bluebookfilePaths =
        _prefs!.getStringList("blue book ${StaticVarMethod.deviceId}");
    rootpermitfilePaths =
        _prefs!.getStringList("route permit ${StaticVarMethod.deviceId}");
    insurencefilePaths =
        _prefs!.getStringList("Insurance ${StaticVarMethod.deviceId}");
    blueBookExpiryDate =
        _prefs!.getString("expiry blue book ${StaticVarMethod.deviceId}");
    rootPermitExpiryDate =
        _prefs!.getString("expiry route permit ${StaticVarMethod.deviceId}");
    insurenceExpiryDate =
        _prefs!.getString("expiry insurance ${StaticVarMethod.deviceId}");
    setState(() {});
  }

  // List<XFile>? imagefiles;
  // List<XFile>? licensefiles;
  List<XFile>? bluebookfiles;
  List<XFile>? rootpermitfiles;
  List<XFile>? insurencefiles;
  // List<String>? licensefilePaths;
  List<String>? bluebookfilePaths;
  List<String>? rootpermitfilePaths;
  List<String>? insurencefilePaths;
  String? blueBookExpiryDate;
  String? rootPermitExpiryDate;
  String? insurenceExpiryDate;

  Future<void> _selectExpiryDate(
      BuildContext context, String uploadType) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      if (uploadType.startsWith("b")) {
        setState(() {
          blueBookExpiryDate = picked.toString();
          _prefs!.setString("expiry $uploadType", blueBookExpiryDate!);
        });
      } else if (uploadType.startsWith("r")) {
        setState(() {
          rootPermitExpiryDate = picked.toString();
          _prefs!.setString("expiry $uploadType", rootPermitExpiryDate!);
        });
      } else {
        setState(() {
          insurenceExpiryDate = picked.toString();
          _prefs!.setString("expiry $uploadType", insurenceExpiryDate!);
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
        title: const Text('Upload Document'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: HomeScreen.primaryDark,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              uploadBox('blue book ${StaticVarMethod.deviceId}', 'blue book',
                  onTap: () async {
                try {
                  List<XFile>? pickedfiles = await imgpicker.pickMultiImage();
                  if (pickedfiles != null) {
                    bluebookfiles = pickedfiles;
                    bluebookfilePaths =
                        bluebookfiles!.map((e) => e.path).toList();
                    _prefs?.setStringList(
                        "blue book ${StaticVarMethod.deviceId}",
                        bluebookfilePaths!);
                    setState(() {});
                  } else {}
                } catch (_) {}
              }),
              uploadBox(
                  'route permit ${StaticVarMethod.deviceId}', 'route permit',
                  onTap: () async {
                try {
                  List<XFile>? pickedfiles = await imgpicker.pickMultiImage();
                  //you can use ImageCourse.camera for Camera capture
                  if (pickedfiles != null) {
                    rootpermitfiles = pickedfiles;
                    rootpermitfilePaths =
                        rootpermitfiles!.map((e) => e.path).toList();
                    _prefs?.setStringList(
                        "route permit ${StaticVarMethod.deviceId}",
                        rootpermitfilePaths!);
                    setState(() {});
                  } else {}
                } catch (_) {}
              }),
              uploadBox('Insurance ${StaticVarMethod.deviceId}', 'Insurance',
                  onTap: () async {
                try {
                  List<XFile>? pickedfiles = await imgpicker.pickMultiImage();
                  //you can use ImageCourse.camera for Camera capture
                  if (pickedfiles != null) {
                    insurencefiles = pickedfiles;
                    insurencefilePaths =
                        insurencefiles!.map((e) => e.path).toList();
                    _prefs?.setStringList(
                        "insurance ${StaticVarMethod.deviceId}",
                        insurencefilePaths!);
                    setState(() {});
                  } else {}
                } catch (_) {}
              }),
            ],
          ),
        ),
      ),
    );
  }

  uploadBox(uploadtype, uploadTitle, {required VoidCallback onTap}) {
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
                  'Upload your $uploadTitle',
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
                  child: uploadtype.toString().startsWith("b")
                      ? Text('${blueBookExpiryDate ?? 'choose'} ')
                      : uploadtype.toString().startsWith("r")
                          ? Text('${rootPermitExpiryDate ?? 'choose'} ')
                          : Text('${insurenceExpiryDate ?? 'choose'} '),
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
                            padding: const EdgeInsets.all(8.0),
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
                                    width: 157,
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
