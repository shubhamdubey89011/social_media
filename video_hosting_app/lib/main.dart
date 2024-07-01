import 'package:corp_tale/auth_pages/login_screen.dart';
import 'package:corp_tale/auth_pages/phone_login_screen.dart';
import 'package:corp_tale/auth_pages/signup_screen.dart';
import 'package:corp_tale/pages/posts_pages/add_post_page.dart';
import 'package:corp_tale/pages/posts_pages/anonymous_page.dart.dart';
import 'package:corp_tale/pages/posts_pages/home_screen.dart';
import 'package:corp_tale/pages/profile_pages/edit_profile_page.dart';
import 'package:corp_tale/pages/profile_pages/profile_page.dart';
import 'package:corp_tale/pages/profile_pages/user_profile.dart';
import 'package:corp_tale/pages/profile_pages/users_list_page.dart';
import 'package:corp_tale/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/usersList') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('currentUserId')) {
            throw ArgumentError(
                'currentUserId is required for /usersList route');
          }
          return MaterialPageRoute(
            builder: (context) {
              return UserListPage(currentUserId: args['currentUserId']);
            },
          );
        } else if (settings.name == '/userprofilePage') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('currentUserId') ||
              !args.containsKey('targetUserId')) {
            throw ArgumentError(
                'currentUserId and targetUserId are required for /userprofilePage route');
          }
          return MaterialPageRoute(
            builder: (context) {
              return UserProfile(
                currentUserId: args['currentUserId'],
                targetUserId: args['targetUserId'],
              );
            },
          );
        }
        // Add other routes here
        return null;
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/imageList': (context) {
          // Get current user ID from Firebase Authentication
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          if (user == null) {
            // Handle scenario where user is not logged in
            // You can redirect to login screen or handle it accordingly
            throw ArgumentError('User not authenticated');
          }
          return ImageListPage(currentUserId: user.uid); // Pass current user ID
        },
        '/phone-login': (context) => const PhoneLoginScreen(),
        '/addImage': (context) => const AddImagePage(),
        '/profilePage': (context) => const ProfilePage(),
        '/editprofilePage': (context) => const EditProfilePage(),
        '/anonymouspage': (context) => const AnonymousPage(),
      },
    );
  }
}
