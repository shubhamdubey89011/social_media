// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corp_tale/auth_pages/login_screen.dart';
import 'package:corp_tale/pages/posts_pages/home_screen.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  late TextEditingController emailController,
      passwordController,
      nameController,
      dobController,
      cNameController;

  var isLoading = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  SharedPreferences? preferences;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    dobController = TextEditingController();
    cNameController = TextEditingController();
  }

  Future<void> initSharedPreferences(BuildContext context) async {
    preferences = await SharedPreferences.getInstance();
    checkLogin(context);
  }

  void checkLogin(BuildContext context) {
    if (preferences != null) {
      final bool isLoggedIn = preferences!.getBool('isLoggedIn') ?? false;
      if (isLoggedIn) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              // Get current user ID from Firebase Authentication
              final FirebaseAuth _auth = FirebaseAuth.instance;
              final User? user = _auth.currentUser;
              if (user == null) {
                // Handle scenario where user is not logged in
                // You can redirect to login screen or handle it accordingly
                throw ArgumentError('User not authenticated');
              }
              return ImageListPage(
                  currentUserId: user.uid); // Pass current user ID
            },
          ),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      print("SharedPreferences is null");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    dobController.dispose();
    cNameController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (!GetUtils.isEmail(value ?? "")) {
      return "Provide a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be of 6 characters";
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? validateComName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  void login(BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await preferences!.setBool('isLoggedIn', true);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              // Get current user ID from Firebase Authentication
              final FirebaseAuth _auth = FirebaseAuth.instance;
              final User? user = _auth.currentUser;
              if (user == null) {
                // Handle scenario where user is not logged in
                // You can redirect to login screen or handle it accordingly
                throw ArgumentError('User not authenticated');
              }
              return ImageListPage(
                  currentUserId: user.uid); // Pass current user ID
            },
          ),
          (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );
      } catch (e) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        rethrow;
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> signup(BuildContext context) async {
    if (signupFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'dateOfBirth': emailController.text.trim(),
          'companyName': emailController.text.trim(),
        });

        await preferences!.setBool('isLoggedIn', true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              // Get current user ID from Firebase Authentication
              final FirebaseAuth _auth = FirebaseAuth.instance;
              final User? user = _auth.currentUser;
              if (user == null) {
                // Handle scenario where user is not logged in
                // You can redirect to login screen or handle it accordingly
                throw ArgumentError('User not authenticated');
              }
              return ImageListPage(
                  currentUserId: user.uid); // Pass current user ID
            },
          ),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful")),
        );
      } catch (e) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        rethrow;
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoading.value = true;
    try {
      await auth.signOut();
      await preferences!.setBool('isLoggedIn', false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
