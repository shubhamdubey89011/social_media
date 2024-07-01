// ignore_for_file: use_build_context_synchronously, avoid_single_cascade_in_expression_statements, unused_element, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:corp_tale/constants/color_const.dart';

class AddImagePage extends StatefulWidget {
  const AddImagePage({super.key});

  @override
  _AddImagePageState createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _clearImageFilePath(); // Clear any previously saved image file path
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveImageFilePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imageFilePath', path);
  }

  Future<String?> _getImageFilePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('imageFilePath');
  }

  Future<void> _clearImageFilePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('imageFilePath');
  }

  Future<void> _pickImage() async {
    // Check if permissions are granted before proceeding
    var cameraStatus = await Permission.camera.request();
    // var storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        _saveImageFilePath(pickedFile.path);
        // Adjust maxLines of descriptionController
        descriptionController..clearComposing();
      }
    } else {
      // Handle case where either or both permissions are not granted
      if (!cameraStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Permissions are required to pick an image")),
        );
      }
    }
  }

  Future<void> _upload(BuildContext context) async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? downloadUrl;
      if (_imageFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child("images/$fileName");
        UploadTask uploadTask = storageReference.putFile(_imageFile!);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {},
            onError: (Object e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: $e")),
          );
        });

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      }

      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection("posts").add({
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': downloadUrl,
        'uploadedBy': _isAnonymous ? 'anonymous' : user?.uid,
        'uploadedAt': Timestamp.now(),
        'likes': 0,
        'comments': [],
        'type': downloadUrl != null ? 'image' : 'text',
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload successful")),
      );

      // Clear saved image file path from SharedPreferences
      await _clearImageFilePath();

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload: $e")),
      );
    }
  }

  Future<bool> requestPermissions() async {
    // Request camera and storage permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: ColorConstants.textColor),
        backgroundColor: ColorConstants.blue1,
        title: const Text(
          'Add Post',
          style: TextStyle(color: ColorConstants.textColor),
        ),
        actions: [
          TextButton(
              onPressed: () {
                _upload(context);
              },
              child: const Text(
                'Post',
                style: TextStyle(color: ColorConstants.textColor),
              ))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide keyboard and unfocus text fields when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: ColorConstants.linearGradientColor3,
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  style: const TextStyle(color: ColorConstants.textColor),
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      maxLines: null,
                      controller: descriptionController,
                      style: const TextStyle(color: ColorConstants.textColor),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Write Your Post...',
                        hintStyle: TextStyle(color: ColorConstants.textColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.image,
                        color: ColorConstants.textColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (_imageFile != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Image:',
                              style: TextStyle(color: ColorConstants.textColor),
                            ),
                            const SizedBox(height: 10),
                            Image.file(
                              _imageFile!,
                              height: MediaQuery.of(context).size.width,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _isAnonymous,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAnonymous = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      'Post as Anonymous',
                      style: TextStyle(color: ColorConstants.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading ? const CircularProgressIndicator() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
