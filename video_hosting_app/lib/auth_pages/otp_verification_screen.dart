// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/pages/posts_pages/post_list_item.dart';
import 'package:corp_tale/pages/posts_pages/home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;

  const OTPVerificationScreen({super.key, required this.verificationId});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> _verifyOTP() async {
    String smsCode = otpController.text.trim();

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _saveUserDataToFirestore(userCredential.user);
      await preferences?.setBool('isLoggedIn', true);
      Navigator.push(
        context,
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
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> _saveUserDataToFirestore(User? user) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('MobileUser')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'signInMethod': user.providerData[0].providerId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: ColorConstants.linearGradientColor5)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: otpController,
                style: const TextStyle(color: ColorConstants.textColor),
                decoration: const InputDecoration(
                    labelText: 'OTP',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                    hintText: 'Enter OTP sent to your given Mobile Number',
                    hintStyle: TextStyle(color: ColorConstants.textColor)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOTP,
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
