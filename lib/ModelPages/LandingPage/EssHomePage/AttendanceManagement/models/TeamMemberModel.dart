class TeamMemberModel {
  final String icon;
  final String username;
  final String empname;
  final String designation;

  TeamMemberModel({
    required this.icon,
    required this.username,
    required this.empname,
    required this.designation,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) => TeamMemberModel(
        icon: json["icon"],
        username: json["username"],
        empname: json["empname"],
        designation: json["designation"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "username": username,
        "empname": empname,
        "designation": designation,
      };
}
