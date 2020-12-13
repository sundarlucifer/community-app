import 'package:community_app/screens/events_screen.dart';
import 'package:community_app/screens/home_screen.dart';
import 'package:community_app/screens/loading_screen.dart';
import 'package:community_app/screens/login_screen.dart';
import 'package:community_app/screens/post_screen.dart';
import 'package:community_app/screens/profile_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _routes = <String, WidgetBuilder>{
    HomeScreen.TAG: (_) => HomeScreen(),
    EventsScreen.TAG: (_) => EventsScreen(),
    PostScreen.TAG: (_) => PostScreen(),
    ProfileScreen.TAG: (_) => ProfileScreen(),
    LoginScreen.TAG: (_) => LoginScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: authService.authState,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done)
            return snapshot.hasData ? HomeScreen() : LoginScreen();
          else
            return LoadingScreen();
        },
      ),
      routes: _routes,
    );
  }
}
