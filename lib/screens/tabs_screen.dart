import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:absensi_honor_android/constant.dart';
import 'package:absensi_honor_android/screens/history_screen.dart';
import 'package:absensi_honor_android/screens/home_screen.dart';
import 'package:absensi_honor_android/screens/profile_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;
  

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        SystemNavigator.pop();
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

  
  
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _determinePosition(),
        builder: ((context, snapshot) {
          return IndexedStack(
            index: _selectedIndex,
            children: [
              HomeScreen(),
              _selectedIndex == 1 ? HistoryScreen() : Text(''),
              _selectedIndex == 2 ? ProfileScreen() : Text('')
            ],
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'My Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
