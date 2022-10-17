import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:absensi_honor_android/constant.dart';
import 'package:intl/intl.dart';
import 'package:absensi_honor_android/network/api/auth/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_honor_android/network/api/auth/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isWaitEnter = false;
  bool isWaitExit = false;

  bool waitData = false;

  String? userId = '';
  String? nameOfUser = '';
  String? lastAttendance = '';

  // test purpose
  // late TextEditingController _destinationLatitudeController;
  // late TextEditingController _destinationLongitudeController;

  // location of kejati sumsel
  final destinationLatitude = -3.01533;
  final destinationLongitude = 104.77826;

  Future<void> auth() async {
    final storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final accessToken = await storage.read(key: 'access_token');
    // prefs.clear();
    if (accessToken == null) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      if (prefs.containsKey('user')) {
        final user = prefs.getStringList('user');

        setState(() {
          userId = user?[0];
          nameOfUser = user?[1];
          lastAttendance = user?[2];
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth();
    attendanceToday();
  }

  attendanceToday() async {
    final date = DateTime.now();

    final dateStartEnter =
        DateTime(date.year, date.month, date.day, 7, 50); // 7 50
    final dateEndEnter = dateStartEnter.add(Duration(hours: 1));
    final days = DateFormat('EEEE').format(date);
    if (days == 'Saturday' || days == 'Sunday') {
      isEnterRangeTime = false;
      isExitRangeTime = false;
    } else {
      if (date.millisecondsSinceEpoch > dateStartEnter.millisecondsSinceEpoch &&
          date.millisecondsSinceEpoch < dateEndEnter.millisecondsSinceEpoch) {
        isEnterRangeTime = true;
      } else {
        isEnterRangeTime = false;
      }

      final dateStartExit =
          DateTime(date.year, date.month, date.day, 15, 50); // 15 50
      final dateEndExit = dateStartExit.add(Duration(hours: 1));

      if (date.millisecondsSinceEpoch > dateStartExit.millisecondsSinceEpoch &&
          date.millisecondsSinceEpoch < dateEndExit.millisecondsSinceEpoch) {
        isExitRangeTime = true;
      } else {
        isExitRangeTime = false;
      }
    }

    final prefs = await SharedPreferences.getInstance();

    // var exitDateAttendance = null;
    if (prefs.containsKey('entered_date')) {
      final currentEnteredDate = DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt('entered_date') ?? 0);

      if (date.day == currentEnteredDate.day &&
          date.month == currentEnteredDate.month &&
          date.year == currentEnteredDate.year) {
        setState(() {
          isEnterDone = true;
        });
      }
    } else {
      if (lastAttendance == '' || lastAttendance == null) {
        try {
          final user = await UserService().getMe();
          if (user.data['lastAttendance'] != null) {
            final attendance = await AttendanceService()
                .getAttendance(user.data['lastAttendance']);

            final lastEnteredDate =
                DateTime.parse(attendance.data['enteredAt']);

            if (lastEnteredDate.year == date.year &&
                lastEnteredDate.month == date.month &&
                lastEnteredDate.day == date.day) {
              await prefs.setInt('enter_id', attendance.data['id']);
            }

            await prefs.setInt(
                'entered_date', lastEnteredDate.millisecondsSinceEpoch);
            await prefs.setInt(
                'exited_date', lastEnteredDate.millisecondsSinceEpoch);
            nameOfUser = user.data['name'];

            // exitDateAttendance = attendance.data['exitedAt'];

            if (date.day == lastEnteredDate.day &&
                date.month == lastEnteredDate.month &&
                date.year == lastEnteredDate.year) {
              setState(() {
                isEnterDone = true;
              });
            }
          }
        } catch (err) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        }
      }
    }

    if (prefs.containsKey('exited_date')) {
      final currentExitedDate =
          DateTime.fromMillisecondsSinceEpoch(prefs.getInt('exited_date') ?? 0);

      if (date.day == currentExitedDate.day &&
          date.month == currentExitedDate.month &&
          date.year == currentExitedDate.year) {
        setState(() {
          isExitDone = true;
        });
      }
    }
  }

  bool isEnterDone = false;
  bool isExitDone = false;

  bool isEnterRangeTime = true;
  bool isExitRangeTime = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            // color: primaryColor,
            padding: EdgeInsets.all(20.0),
            // color: primaryColor,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(180),
                  bottomRight: Radius.circular(180)),
            ),
            child: new Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 20,
                      ),
                    ),
                    Text(
                      'Hi ' + (nameOfUser ?? ''),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                  child: StreamBuilder(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                    ),
                    builder: ((context, snapshot) {
                      var date = DateTime.now();
                      return Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top: 30)),
                          Text(
                            DateFormat('EEEE').format(date),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            DateFormat('hh:mm:ss').format(date),
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(date),
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white),
                          )
                        ],
                      );
                    }),
                  ),
                ),
                // Padding(padding: EdgeInsets.only(top: 20)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(30),
            margin: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                isWaitEnter == false
                    ? OutlinedButton(
                        onPressed: isEnterRangeTime == true &&
                                isEnterDone == false
                            ? () async {
                                setState(() {
                                  isWaitEnter = true;
                                });

                                final currentLocation =
                                    await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.high);
                                final distance = Geolocator.distanceBetween(
                                    currentLocation.latitude,
                                    currentLocation.longitude,
                                    destinationLatitude,
                                    destinationLongitude);

                                // if distance on meters
                                if (distance <= 200) {
                                  try {
                                    final prefs =
                                        await SharedPreferences.getInstance();

                                    final response = await AttendanceService()
                                        .enterAttendance();
                                    if (response.statusCode == 201) {
                                      await prefs.setInt(
                                          'entered_date',
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                      await prefs.setInt('exited_date', 0);
                                      await prefs.setInt(
                                          'enter_id', response.data['id']);
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.success,
                                        title: 'Absen Masuk Berhasil',
                                        autoHide: Duration(seconds: 5),
                                      ).show().whenComplete(() {
                                        setState(() {
                                          isWaitEnter = false;
                                          isEnterDone = true;
                                        });
                                      });
                                    } else {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/login',
                                              (Route<dynamic> route) => false);
                                    }
                                  } catch (err) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      title: 'Error',
                                      desc: 'Something was wrong!',
                                      autoHide: Duration(seconds: 5),
                                    ).show().whenComplete(() {
                                      setState(() {
                                        isWaitEnter = false;
                                      });
                                    });
                                  }
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    title: 'Absen Masuk Gagal',
                                    desc: 'Lokasi Terlalu jauh',
                                    autoHide: Duration(seconds: 5),
                                  ).show().whenComplete(() {
                                    setState(() {
                                      isWaitEnter = false;
                                    });
                                  });
                                }
                              }
                            : () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Absen Masuk',
                              style: TextStyle(
                                  color: isEnterRangeTime == true &&
                                          isEnterDone == false
                                      ? Colors.white
                                      : Colors.grey),
                            ),
                            isEnterDone ? Icon(Icons.done) : Text('')
                          ],
                        ),
                        style: ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(Size(
                              MediaQuery.of(context).size.width * 0.6, 40)),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                              isEnterRangeTime == true && isEnterDone == false
                                  ? primaryColor
                                  : Colors.transparent),
                        ),
                      )
                    : CircularProgressIndicator(),
                Padding(padding: EdgeInsets.only(top: 6)),
                isWaitExit == false
                    ? OutlinedButton(
                        onPressed: isExitRangeTime == true &&
                                isExitDone == false
                            ? () async {
                                try {
                                  setState(() {
                                    isWaitExit = true;
                                  });

                                  final currentLocation =
                                      await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high);
                                  final distance = Geolocator.distanceBetween(
                                      currentLocation.latitude,
                                      currentLocation.longitude,
                                      destinationLatitude,
                                      destinationLongitude);
                                  // if distance on meters
                                  if (distance >= 200) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final enterId = prefs.getInt('enter_id');
                                    
                                    final response = await AttendanceService()
                                        .exitDone(enterId.toString());
                                    if (response.statusCode == 200) {
                                      await prefs.setInt(
                                          'exited_date',
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.success,
                                        title: 'Absen Pulang Berhasil',
                                        autoHide: Duration(seconds: 5),
                                      ).show().whenComplete(() {
                                        setState(() {
                                          isWaitExit = false;
                                          isExitDone = true;
                                        });
                                      });
                                    } else {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/login',
                                              (Route<dynamic> route) => false);
                                    }
                                  } else {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      title: 'Absen Pulang Gagal',
                                      desc: 'Jarak Terlalu Jauh',
                                      autoHide: Duration(seconds: 5),
                                    ).show().whenComplete(() {
                                      setState(() {
                                        isWaitExit = false;
                                      });
                                    });
                                  }
                                } catch (err) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    title: 'Error',
                                    desc: 'Something was wrong!',
                                    autoHide: Duration(seconds: 5),
                                  ).show().whenComplete(() {
                                    setState(() {
                                      isWaitExit = false;
                                    });
                                  });
                                }
                              }
                            : () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Absen Pulang',
                              style: TextStyle(
                                  color: isExitRangeTime == true &&
                                          isExitDone == false
                                      ? Colors.white
                                      : Colors.grey),
                            ),
                            isExitDone ? Icon(Icons.done) : Text('')
                          ],
                        ),
                        style: ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(Size(
                              MediaQuery.of(context).size.width * 0.6, 40)),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                              isExitRangeTime == true && isExitDone == false
                                  ? primaryColor
                                  : Colors.transparent),
                        ),
                      )
                    : CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
