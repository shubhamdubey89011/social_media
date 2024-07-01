import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController userImageUrlController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController cNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          usernameController.text = data['username'] ?? '';
          userImageUrlController.text = data['profilePictureUrl'] ?? '';
          mobileNumberController.text = data['mobileNumber'] ?? '';
          cNameController.text = data['companyName'] ?? '';
          dobController.text = data['dateOfBirth'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

      User? user = _auth.currentUser;
      if (user != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${user.uid}.jpg');

          TaskSnapshot uploadTask = await storageRef.putFile(_image!);

          final downloadUrl = await uploadTask.ref.getDownloadURL();

          setState(() {
            userImageUrlController.text = downloadUrl;
          });

          // Update Firestore with the new profile picture URL
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'profilePictureUrl': downloadUrl,
          });

          print("Profile picture URL updated in Firestore: $downloadUrl");
        } catch (e) {
          // Handle errors
          print("Failed to upload image or update Firestore: $e");
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'username': usernameController.text,
        'profilePictureUrl': userImageUrlController.text,
        'mobileNumber': mobileNumberController.text,
        'companyName': cNameController.text,
        'dateOfBirth': dobController.text,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: ColorConstants.textColor),
        backgroundColor: ColorConstants.blue1,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: ColorConstants.textColor),
        ),
      ),
      body: Container(
        height: 700,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: ColorConstants.linearGradientColor2,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_image != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(_image!),
                  )
                else if (userImageUrlController.text.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userImageUrlController.text),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.blue1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Select Image',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstants.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                    hintText: 'Enter your username',
                    hintStyle: TextStyle(color: ColorConstants.textColor),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: ColorConstants.textColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: mobileNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                    hintText: 'Enter your Mobile Number',
                    hintStyle: TextStyle(color: ColorConstants.textColor),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: ColorConstants.textColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cNameController,
                  // keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                    hintText: 'Enter your Company Name',
                    hintStyle: TextStyle(color: ColorConstants.textColor),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: ColorConstants.textColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dobController,
                  // keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'DOB',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                    hintText: 'Enter your Date of Birth',
                    hintStyle: TextStyle(color: ColorConstants.textColor),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: ColorConstants.textColor),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.blue1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstants.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
