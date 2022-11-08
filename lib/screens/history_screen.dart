import 'package:flutter/material.dart';
import 'package:absensi_honor_android/network/api/auth/attendance_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> list = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  Future<void> getAttendancesByMonth(String month) async {
    
    setState(() {
      isWaiting = false;
    });
    final response = await AttendanceService().getAttendancesByMonth(month);
    final getDays = getDaysInMonth(dateNow.year, dateNow.month);
    attendances = [];

    final responseAttendance =
        List.from(response.data).where((e) => e != null).toList();
    for (int i = 1; i <= getDays; i++) {
      if (responseAttendance.isNotEmpty) {
        var firstAttendance = responseAttendance.first;
        var firstEnteredAt = DateTime.parse(firstAttendance['enteredAt']);
        var firstExitedAt = DateTime.parse(firstAttendance['exitedAt'] ?? DateFormat('yyyy-MM-dd').format(DateTime(2017, 10,10)));

        if (firstEnteredAt.day == i && firstExitedAt.day == i) {
          attendances.add(firstAttendance);
          responseAttendance.remove(firstAttendance);
        } else {
          attendances.add({});  
        }
      } else {
        if (DateTime(dateNow.year, monthNumber + 1, i).isBefore(
            DateTime(dateNow.year, dateNow.month, dateNow.day - 1, 23))) {
          attendances.add({});
        }
      }
    }

    setState(() {
      isWaiting = true;
    });

  }

  final DateTime dateNow = DateTime.now();

  int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return daysInMonth[month - 1];
  }

  String monthText = '';
  int monthNumber = 0;
  var attendances = [];
  bool isWaiting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    monthNumber = DateTime.now().month - 1;
    monthText = list[monthNumber];
    getAttendancesByMonth((monthNumber + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              child: Text(
                'History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              padding: EdgeInsets.all(20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    gapPadding: 2.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    menuMaxHeight: 200,
                    isExpanded: true,
                    isDense: true,
                    value: monthText,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(
                      height: 1,
                      color: Colors.black,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        monthText = value!;
                        monthNumber = list.indexOf(value);
                        getAttendancesByMonth((monthNumber + 1).toString());
                        attendances.length;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(width: 10),
                            Text(value + ' ' + dateNow.year.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 16)),
            isWaiting == true
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: attendances.length,
                    itemBuilder: ((context, index) {
                      final days = DateFormat('EEEE').format(
                          DateTime(dateNow.year, dateNow.month, index + 1));
                      bool dayOff = false;
                      bool present = false;
                      if (days == 'Saturday' || days == 'Sunday') {
                        dayOff = true;
                      }

                      return Container(
                        height: 70,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.5, color: Colors.grey.shade400),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dayOff == false
                                  ? Text(
                                      (index + 1).toString() +
                                          ' ' +
                                          DateFormat('MMM').format(DateTime(
                                              dateNow.year, monthNumber + 1)),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: attendances[index].length != 0
                                              ? Colors.black
                                              : Colors.red),
                                    )
                                  : Text(
                                      (index + 1).toString() +
                                          ' ' +
                                          DateFormat('MMM').format(DateTime(
                                              dateNow.year, monthNumber + 1)),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.amber,
                                      )),
                              dayOff == false
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        attendances[index].length != 0
                                            ? Text('Hadir')
                                            : Text(
                                                'Tidak Hadir',
                                                style: TextStyle(
                                                  color: attendances[index]
                                                              .length !=
                                                          0
                                                      ? Colors.black
                                                      : Colors.red,
                                                ),
                                              ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Hari Libur',
                                          style: TextStyle(color: Colors.amber),
                                        )
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
