import 'dart:convert';

class AttendanceDataModel {
  final String date;
  final String status;
  final String clockIn;
  final String clockOut;
  final String workingHours;

  AttendanceDataModel({
    required this.date,
    required this.status,
    required this.clockIn,
    required this.clockOut,
    required this.workingHours,
  });

  factory AttendanceDataModel.fromRawJson(String str) => AttendanceDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json) => AttendanceDataModel(
        date: json["date"],
        status: json["status"],
        clockIn: json["clockIn"],
        clockOut: json["clockOut"],
        workingHours: json["workingHours"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "status": status,
        "clockIn": clockIn,
        "clockOut": clockOut,
        "workingHours": workingHours,
      };

  static final List<Map<String, dynamic>> _attendanceData = [
    {
      "date": "1 MON",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:15 pm",
      "location": "Location",
      "workingHours": "09h 15m"
    },
    {"date": "2 TUE", "status": "Sick Leave", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "3 WED", "status": "Casual Leave", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {
      "date": "4 THU",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "05:45 pm",
      "location": "Location",
      "workingHours": "08h 45m"
    },
    {
      "date": "5 FRI",
      "status": "Half Day",
      "clockIn": "09:00 am",
      "clockOut": "01:00 pm",
      "location": "Location",
      "workingHours": "04h 00m"
    },
    {"date": "6 SAT", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "7 SUN", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {
      "date": "8 MON",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:30 pm",
      "location": "Location",
      "workingHours": "09h 30m"
    },
    {
      "date": "9 TUE",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:00 pm",
      "location": "Location",
      "workingHours": "09h 00m"
    },
    {
      "date": "10 WED",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "05:50 pm",
      "location": "Location",
      "workingHours": "08h 50m"
    },
    {
      "date": "11 THU",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:10 pm",
      "location": "Location",
      "workingHours": "09h 10m"
    },
    {
      "date": "12 FRI",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:20 pm",
      "location": "Location",
      "workingHours": "09h 20m"
    },
    {"date": "13 SAT", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "14 SUN", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "15 MON", "status": "Sick Leave", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {
      "date": "16 TUE",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:05 pm",
      "location": "Location",
      "workingHours": "09h 05m"
    },
    {
      "date": "17 WED",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:25 pm",
      "location": "Location",
      "workingHours": "09h 25m"
    },
    {
      "date": "18 THU",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "05:55 pm",
      "location": "Location",
      "workingHours": "08h 55m"
    },
    {
      "date": "19 FRI",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:40 pm",
      "location": "Location",
      "workingHours": "09h 40m"
    },
    {"date": "20 SAT", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "21 SUN", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {
      "date": "22 MON",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:15 pm",
      "location": "Location",
      "workingHours": "09h 15m"
    },
    {
      "date": "23 TUE",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:30 pm",
      "location": "Location",
      "workingHours": "09h 30m"
    },
    {
      "date": "24 WED",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:00 pm",
      "location": "Location",
      "workingHours": "09h 00m"
    },
    {
      "date": "25 THU",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "05:50 pm",
      "location": "Location",
      "workingHours": "08h 50m"
    },
    {
      "date": "26 FRI",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:20 pm",
      "location": "Location",
      "workingHours": "09h 20m"
    },
    {"date": "27 SAT", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {"date": "28 SUN", "status": "Week Off", "clockIn": "", "clockOut": "", "location": "", "workingHours": ""},
    {
      "date": "29 MON",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:10 pm",
      "location": "Location",
      "workingHours": "09h 10m"
    },
    {
      "date": "30 TUE",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:25 pm",
      "location": "Location",
      "workingHours": "09h 25m"
    },
    {
      "date": "31 WED",
      "status": "active",
      "clockIn": "09:00 am",
      "clockOut": "06:15 pm",
      "location": "Location",
      "workingHours": "09h 15m"
    }
  ];

  static List<AttendanceDataModel> sampleData = List.generate(
    _attendanceData.length,
    (index) => AttendanceDataModel.fromJson(
      _attendanceData[index],
    ),
  );
}
