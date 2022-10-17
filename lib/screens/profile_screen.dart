import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> logout() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Padding(
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            // CircleAvatar(
            //   child: Icon(Icons.face),
            // ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/update-profile');
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.face,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      'Update Profile',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              style: ButtonStyle(
                shadowColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: TextButton(
                onPressed: () {
                  logout();
                  setState(() {
                    
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', (Route<dynamic> route) => false);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.output,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                ),
                style: ButtonStyle(
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
