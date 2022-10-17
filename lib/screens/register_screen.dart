import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_honor_android/constant.dart';
import 'package:absensi_honor_android/network/api/auth/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  final _formKey = GlobalKey<FormState>();

  bool isError = false;
  bool usernameError = false;
  bool isWaiting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: [
                Text(
                  'Register',
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
                            usernameError == true
                                ? 'Username sudah digunakan orang lain!'
                                : 'Something was wrong!',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      )
                    : SizedBox(),
                Padding(padding: EdgeInsets.only(bottom: 20)),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.sentiment_neutral_rounded),
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi!';
                    }
                    if (value.length > 99) {
                      return 'Nama terlalu panjang!';
                    }
                    return null;
                  }),
                ),
                Padding(padding: EdgeInsets.only(bottom: 16)),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.account_circle_outlined),
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Username harus diisi!';
                    }
                    if (value.length > 80) {
                      return 'Username terlalu panjang!';
                    }

                    return null;
                  }),
                ),
                Padding(padding: EdgeInsets.only(bottom: 16)),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                  obscureText: true,
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi!';
                    }
                    if (!value.contains(new RegExp(r'[0-9]'))) {
                      return 'Password harus dengan angka! contoh: ujik123';
                    }
                    return null;
                  }),
                ),
                Padding(padding: EdgeInsets.only(bottom: 16)),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ulangi Password',
                    prefixIcon: Icon(Icons.lock_open),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ulangi Password harus diisi!';
                    }

                    if (value != _passwordController.text) {
                      return 'Password tidak sama!';
                    }
                    return null;
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                isWaiting == false
                    ? ElevatedButton(
                        onPressed: () async {
                          // valid
                          if (_formKey.currentState!.validate()) {
                            try {
                              setState(() {
                                isWaiting = true;
                              });
                              final response = await UserService().register(
                                  _nameController.text,
                                  _usernameController.text,
                                  _passwordController.text);
                              if (response.statusCode == 201) {
                                final loginResponse = await UserService().login(
                                    _usernameController.text,
                                    _passwordController.text);
                                if (loginResponse.statusCode == 200) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setStringList('userFullInfo', [
                                    _nameController.text,
                                  ]);
                                  prefs.setStringList('user', [response.data['id'].toString(), _nameController.text]);
                                  setState(() {
                                    Navigator.of(context).pushNamed('/tabs');
                                  });
                                } else {
                                  setState(() {
                                    isError = true;
                                    isWaiting = false;
                                  });
                                }
                              }
                            } catch (error) {
                              if (error is DioError) {
                                if (error.response?.data['detail'] ==
                                    'username: This value is already used.') {
                                  usernameError = true;
                                }
                              }
                              setState(() {
                                isError = true;
                                isWaiting = false;
                              });
                            }
                          }
                        },
                        child: Text('Daftar'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(primaryColor)),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.4),
                        child: CircularProgressIndicator(),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
