import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {

  static const TAG = 'login-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
