import 'package:community_app/screens/home_screen.dart';
import 'package:community_app/screens/loading_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const TAG = 'login-screen';

  _signIn(context) {
    authService.signInWithGoogle().then((u) {
      if (u != null) Navigator.pushReplacementNamed(context, HomeScreen.TAG);
    });
  }

  @override
  Widget build(BuildContext context) {
    _signIn(context);
    return LoadingScreen();
  }
}
