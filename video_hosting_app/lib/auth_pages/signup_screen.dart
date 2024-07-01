import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:corp_tale/auth_pages/auth_controllers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.put(AuthController());

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      authController.dobController.text =
          DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: authController.signupFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: authController.nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  return authController.validateName(value);
                },
              ),
              TextFormField(
                controller: authController.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  return authController.validateEmail(value);
                },
              ),
              TextFormField(
                controller: authController.passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  return authController.validatePassword(value);
                },
              ),
              TextFormField(
                controller: authController.dobController,
                decoration: const InputDecoration(
                  labelText: 'DOB',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  return authController.validateDOB(value);
                },
              ),
              TextFormField(
                controller: authController.cNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  return authController.validateComName(value);
                },
              ),
              const SizedBox(height: 20),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => authController.signup(context),
                      child: const Text('Signup'),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
