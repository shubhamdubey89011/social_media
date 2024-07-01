// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corp_tale/auth_pages/auth_controllers.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/auth_pages/phone_login_screen.dart';
import 'package:corp_tale/auth_pages/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false)
          .initSharedPreferences(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: ColorConstants.linearGradientColor5,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: Provider.of<AuthController>(context).loginFormKey,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(color: ColorConstants.textColor),
                  controller:
                      Provider.of<AuthController>(context).emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                  ),
                  validator: (value) {
                    return Provider.of<AuthController>(context, listen: false)
                        .validateEmail(value!);
                  },
                ),
                TextFormField(
                  style: const TextStyle(color: ColorConstants.textColor),
                  controller:
                      Provider.of<AuthController>(context).passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: ColorConstants.textColor),
                  ),
                  obscureText: true,
                  validator: (value) {
                    return Provider.of<AuthController>(context, listen: false)
                        .validatePassword(value!);
                  },
                ),
                const SizedBox(height: 20),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return authController.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => authController.login(context),
                            child: const Text('Login'),
                          );
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: ColorConstants.textColor),
                      ),
                      Text(
                        "Sign up",
                        style: TextStyle(
                            color: ColorConstants.textColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: ColorConstants.textColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'OR',
                  style:
                      TextStyle(color: ColorConstants.textColor, fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: ColorConstants.textColor,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PhoneLoginScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Log In with ",
                        style: TextStyle(color: ColorConstants.textColor),
                      ),
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                            color: ColorConstants.textColor, fontSize: 16),
                      ),
                    ],
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
