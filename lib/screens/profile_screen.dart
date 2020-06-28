import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  static const TAG = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: Center(child: Text('Profile Screen')),
    );
  }
}