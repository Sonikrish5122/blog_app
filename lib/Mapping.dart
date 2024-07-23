import 'package:flutter/material.dart';
import 'package:blog_app/LoginRegisterPage.dart';
import 'package:blog_app/HomePage.dart';
import 'Authentication.dart';

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class MappingPage extends StatefulWidget {
  final Auth auth;

  MappingPage({required this.auth});

  @override
  State<StatefulWidget> createState() {
    return _MappingPageState();
  }
}

class _MappingPageState extends State<MappingPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((firebaseUserId) {
      setState(() {
        authStatus = firebaseUserId == null
            ? AuthStatus.notSignedIn
            : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return LoginRegisterPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return HomePage(
          auth: widget.auth,
          onSignedOut: _signOut,
        );
    }
  }
}