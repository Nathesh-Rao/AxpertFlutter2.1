class LeaveBalanceModel {
  final String leaveType;
  final String totalLeaves;
  final String balanceLeaves;

  LeaveBalanceModel({
    required this.leaveType,
    required this.totalLeaves,
    required this.balanceLeaves,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) => LeaveBalanceModel(
        leaveType: json["leave_type"],
        totalLeaves: json["total_leaves"],
        balanceLeaves: json["balance_leaves"],
      );

  Map<String, dynamic> toJson() => {
        "leave_type": leaveType,
        "total_leaves": totalLeaves,
        "balance_leaves": balanceLeaves,
      };
}
