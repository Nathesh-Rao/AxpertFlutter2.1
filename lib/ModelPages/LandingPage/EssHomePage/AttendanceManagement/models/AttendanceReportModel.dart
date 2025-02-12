class AttendanceReportModel {
  final String date;
  final String intime;
  final String outtime;
  final String workingHours;
  final String status;

  AttendanceReportModel({
    required this.date,
    required this.intime,
    required this.outtime,
    required this.workingHours,
    required this.status,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) => AttendanceReportModel(
        date: json["date"],
        intime: json["intime"],
        outtime: json["outtime"],
        workingHours: json["working_hours"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "intime": intime,
        "outtime": outtime,
        "working_hours": workingHours,
        "status": status,
      };
}
