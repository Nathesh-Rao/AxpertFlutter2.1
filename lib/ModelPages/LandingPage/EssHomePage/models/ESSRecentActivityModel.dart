import 'dart:convert';

class EssRecentActivityModel {
  final String icon;
  final String title;
  final String subtitle;
  final String info1;
  final String info2;
  final String isactive;
  final String pageid;

  EssRecentActivityModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.info1,
    required this.info2,
    required this.isactive,
    required this.pageid,
  });

  factory EssRecentActivityModel.fromRawJson(String str) =>
      EssRecentActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EssRecentActivityModel.fromJson(Map<String, dynamic> json) =>
      EssRecentActivityModel(
        icon: json["icon"],
        title: json["title"],
        subtitle: json["subtitle"],
        info1: json["info1"],
        info2: json["info2"],
        isactive: json["isactive"],
        pageid: json["pageid"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "caption": title,
        "subtitle": subtitle,
        "info1": info1,
        "info2": info2,
        "isactive": isactive,
        "pageid": pageid,
      };
}
