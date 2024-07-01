// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/pages/posts_pages/post_list_item.dart';
import 'package:corp_tale/auth_pages/otp_verification_screen.dart';
import 'package:corp_tale/pages/posts_pages/home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final List<Map<String, dynamic>> _countryCodes = [];
  String _selectedCountryCode = '+1'; // Default to US dial code
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
    _initSharedPreferences();
  }

  Future<void> _loadCountryCodes() async {
    String data = await rootBundle.loadString('assets/country_code.json');
    List<dynamic> jsonResult = json.decode(data);

    setState(() {
      _countryCodes.addAll(jsonResult.cast<Map<String, dynamic>>());
    });

    if (_countryCodes.isNotEmpty) {
      setState(() {
        _selectedCountryCode = _countryCodes[0]['dial_code'];
      });
    }
  }

  Future<void> _initSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
    _checkLogin();
  }

  void _checkLogin() {
    bool isLoggedIn = preferences?.getBool('isLoggedIn') ?? false;
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
  }

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = _selectedCountryCode + phoneController.text.trim();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
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
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message.toString());
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                    verificationId: verificationId,
                  )),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
      appBar: AppBar(title: const Text('Login with Phone')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: ColorConstants.linearGradientColor5),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Baseline(
                    baseline: 25.0, // Adjust this value according to your needs
                    baselineType: TextBaseline.alphabetic,
                    child: DropdownButton<String>(
                      menuMaxHeight: 350,
                      dropdownColor: ColorConstants.blue1,
                      value: _selectedCountryCode,
                      underline: const SizedBox.shrink(), // Hides the underline
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCountryCode = value!;
                        });
                      },
                      items: _countryCodes.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> country) {
                          return DropdownMenuItem<String>(
                            value: country['dial_code'],
                            child: Text(
                              '${country['code']} (${country['dial_code']})',
                              style: const TextStyle(
                                  color: ColorConstants.textColor),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Baseline(
                      baseline:
                          25.0, // Adjust this value according to your needs
                      baselineType: TextBaseline.alphabetic,
                      child: TextField(
                        controller: phoneController,
                        style: const TextStyle(color: ColorConstants.textColor),
                        decoration: const InputDecoration(
                            labelText: 'Enter your Phone Number',
                            labelStyle:
                                TextStyle(color: ColorConstants.textColor)),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
