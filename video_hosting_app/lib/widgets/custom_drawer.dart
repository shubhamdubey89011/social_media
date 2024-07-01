import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:corp_tale/auth_pages/auth_controllers.dart';
import 'package:corp_tale/constants/color_const.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: ColorConstants.linearGradientColor5,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: ColorConstants.textColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              iconColor: Colors.white,
              leading: const Icon(Icons.home),
              title: const Text(
                'Home',
                style: TextStyle(color: ColorConstants.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              iconColor: Colors.white,
              leading: const Icon(Icons.account_circle),
              title: const Text(
                'Profile',
                style: TextStyle(color: ColorConstants.textColor),
              ),
              onTap: () => Navigator.pushNamed(context, '/profilePage'),
            ),
            ListTile(
              iconColor: Colors.white,
              leading: const Icon(Icons.settings),
              title: const Text(
                'Settings',
                style: TextStyle(color: ColorConstants.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              iconColor: Colors.white,
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(color: ColorConstants.textColor),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authController.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
