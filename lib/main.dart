
import 'dart:io';

import 'package:blog_app/Mapping.dart';
import 'package:blog_app/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ?
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA-8gVdwIHrEzbXxZRFSgUuQlnUim5fZdc",
      appId: "1:509356282842:android:dde6189e8f78ff85f0a6e3",
      messagingSenderId: "509356282842",
      projectId: "blogapp-3a0f4",
    ),
  ) : await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Blog App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.pink,
      ),
      home: SplashScreen(),
    );
  }
}

