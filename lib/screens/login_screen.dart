import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_honor_android/constant.dart';
import 'package:absensi_honor_android/network/api/auth/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  bool isValidated = false;
  bool isError = false;
  bool isWaiting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      setState(() {
        isValidated = true;
      });
    } else {
      setState(() {
        isValidated = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Image.asset(
                  'assets/images/logo_kejati.png',
                  height: 140,
                ),
              ),
              Text(
                'Login',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              isError == true
                  ? Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.red.shade100),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Username or password is incorrect.',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w300),
                        ),
                      ),
                    )
                  : SizedBox(),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && _passwordController.text.isNotEmpty) {
                    setState(() {
                      isValidated = true;
                    });
                  } else {
                    setState(() {
                      isValidated = false;
                    });
                  }
                },
              ),
              Padding(padding: EdgeInsets.only(bottom: 16)),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_open),
                ),
                onChanged: ((value) {
                  if (value.isNotEmpty && _usernameController.text.isNotEmpty) {
                    setState(() {
                      isValidated = true;
                    });
                  } else {
                    setState(() {
                      isValidated = false;
                    });
                  }
                }),
                obscureText: true,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              isWaiting == false
                  ? ElevatedButton(
                      onPressed: isValidated == true
                          ? () async {
                              try {
                                setState(() {
                                  isWaiting = true;
                                });

                                final response = await UserService().login(
                                    _usernameController.text,
                                    _passwordController.text);
                                if (response.statusCode == 200) {
                                  final prefs = await SharedPreferences.getInstance();
                                  final user = await UserService().getMe().then((value) {
                                  prefs.setStringList('user', [value.data['id'].toString(), value.data['name'], value.data['lastAttendance']]).whenComplete(() {
                                    setState(() {
                                      Navigator.of(context).pushNamed('/tabs');
                                    });
                                  });
                                    
                                  });
                                } else {
                                  setState(() {
                                    isError = true;
                                    isWaiting = false;
                                    _passwordController.text = '';
                                  });
                                }
                              } catch (err) {
                                setState(() {
                                  isError = true;
                                  isWaiting = false;
                                  _passwordController.text = '';
                                });
                              }
                            }
                          : () {},
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color:
                              isValidated == true ? Colors.white : Colors.grey,
                        ),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              isValidated == true
                                  ? primaryColor
                                  : Colors.grey.shade200),
                          shadowColor: MaterialStateProperty.all<Color>(
                              Colors.transparent)),
                    )
                  : Padding(
                      child: CircularProgressIndicator(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun?',
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      'Daftar',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
