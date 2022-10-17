import 'package:flutter/material.dart';
import 'package:absensi_honor_android/screens/home_screen.dart';
import 'package:absensi_honor_android/screens/login_screen.dart';
import 'package:absensi_honor_android/screens/register_screen.dart';
import 'package:absensi_honor_android/screens/tabs_screen.dart';
import 'package:absensi_honor_android/screens/update_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xffFDDA1F),
      ),
      home: TabsScreen(),
      routes: {
        '/home': ((context) =>  HomeScreen()),
        '/login': ((context) => LoginScreen()),
        '/register': ((context) => RegisterScreen()),
        '/tabs': ((context) => TabsScreen()),
        '/update-profile': ((context) => UpdateProfileScreen())
        }
    );
  }
}

