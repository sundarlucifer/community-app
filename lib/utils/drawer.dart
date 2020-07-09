import 'package:community_app/models/user.dart';
import 'package:community_app/screens/events_screen.dart';
import 'package:community_app/screens/home_screen.dart';
import 'package:community_app/screens/login_screen.dart';
import 'package:community_app/screens/post_screen.dart';
import 'package:community_app/screens/profile_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _userName;
  String _userMail;
  Widget _userPhoto;

  @override
  void initState() {
    User user = authService.user;
    setState(() {
      _userName = user.displayName;
      _userMail = user.email;
      if (user.photoUrl != '') _userPhoto = Image.network(user.photoUrl);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName ?? 'anonymous'),
              accountEmail: Text(_userMail ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: _userPhoto,
              ),
            ),
            ListTile(
              title: Text('DashBoard'),
              leading: Icon(Icons.dashboard),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, HomeScreen.TAG),
            ),
            ListTile(
              title: Text('Events'),
              leading: Icon(Icons.event_note),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, EventsScreen.TAG),
            ),
            ListTile(
              title: Text('Posts'),
              leading: Icon(Icons.forum),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, PostScreen.TAG),
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, ProfileScreen.TAG),
            ),
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => authService.signOut().then((_) =>
                  Navigator.pushReplacementNamed(context, LoginScreen.TAG)),
            ),
          ],
        ),
      ),
    );
  }
}
