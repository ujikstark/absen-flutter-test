import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_honor_android/constant.dart';
import 'package:absensi_honor_android/network/api/auth/user_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _descriptionController;

  final _formKey = GlobalKey<FormState>();
  String userId = '';

  currentData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getStringList('user');
    userId = user?[0] ?? '';
    print(userId);
    if (prefs.containsKey('userFullInfo')) {
      print('yes');
      final userFullInfo = prefs.getStringList('userFullInfo');
      print(userFullInfo?.length);
      if (userFullInfo?.length == 1) {
        _nameController.text = userFullInfo?[0] ?? '';
      } else if (userFullInfo?.length == 2) {
        _nameController.text = userFullInfo?[0] ?? '';
        _addressController.text = userFullInfo?[1] ?? '';
      } else if (userFullInfo?.length == 3) {
        _nameController.text = userFullInfo?[0] ?? '';
        _addressController.text = userFullInfo?[1] ?? '';
        _phoneNumberController.text = userFullInfo?[2] ?? '';
      } else if (userFullInfo?.length == 4)   {
                _nameController.text = userFullInfo?[0] ?? '';
        _addressController.text = userFullInfo?[1] ?? '';
        _phoneNumberController.text = userFullInfo?[2] ?? '';
      _descriptionController.text = userFullInfo?[3] ?? '';
      }


    } else {
        try {
          final user = await UserService().getMe();
          prefs.setStringList('userFullInfo', [
            user.data['name'] ?? '',
            user.data['address'] ?? '',
            user.data['phoneNumber'] ?? '',
            user.data['description'] ?? '',
          ]);
          _nameController.text = user.data['name'] ?? '';
          _addressController.text = user.data['address'] ?? '';
          _phoneNumberController.text = user.data['phoneNumber'] ?? '';
          _descriptionController.text = user.data['description'] ?? '';
        } catch (err) {
          await UserService().logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _descriptionController = TextEditingController();
    print('na');
    currentData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  bool isWaiting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                textInputAction: TextInputAction.done,
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nama Lengkap',
                  labelText: 'Nama Lengkap',
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nomor HP',
                    labelText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP harus diisi!';
                    }
                    if (value.length >= 20) {
                      return 'Nomor HP terlalu panjang!';
                    }
                    if (!value.contains(new RegExp(r'[0-9]'))) {
                      return 'Nomor HP harus angka!';
                    }
                    return null;
                  }),
                ),
              ),
              TextFormField(
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat',
                  hintText: 'Alamat',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi!';
                  }
                  return null;
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  maxLines: null,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Deskripsi',
                    hintText: 'Deskripsi',
                    prefixIcon: Icon(Icons.description),
                    counterText: '',
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi harus diisi!';
                    }
                    if (value.length > 254) {
                      return 'Deskripsi terlalu panjang!';
                    }
                    return null;
                  }),
                  maxLength: 254,
                ),
              ),
              isWaiting == false
                  ? ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            setState(() {
                              isWaiting = true;
                            });
                            final response =
                                await UserService().updateUser(userId, {
                              'name': _nameController.text,
                              'phoneNumber': _phoneNumberController.text,
                              'address': _addressController.text,
                              'description': _descriptionController.text
                            });

                            if (response.statusCode == 200) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setStringList('userFullInfo', [
                                response.data['name'] ?? '',
                                response.data['address'] ?? '',
                                response.data['phoneNumber'] ?? '',
                                response.data['description'] ?? '',
                              ]);
                              setState(() {
                                isWaiting = false;
                              });
                              final user = prefs.getStringList('user');
                              prefs.setStringList('user', [
                                user?[0] ?? '',
                                response.data['name'],
                                user?[2] ?? ''
                              ]);

                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.success,
                                      title: 'Profile Berhasil di update',
                                      autoHide: Duration(seconds: 5))
                                  .show()
                                  .whenComplete(() =>
                                      Navigator.of(context).pushNamed('/tabs'));
                            }
                          } catch (err) {
                            setState(() {
                              isWaiting = false;
                            });
                          }
                        }
                      },
                      child: Text('Update'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(primaryColor),
                      ),
                    )
                  : Padding(
                      child: CircularProgressIndicator(),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
