import 'dart:convert';

class EssRecentActivityModel {
  final String icon;
  final String caption;
  final String subheading;
  final String info1;
  final String info2;
  final String isactive;

  EssRecentActivityModel({
    required this.icon,
    required this.caption,
    required this.subheading,
    required this.info1,
    required this.info2,
    required this.isactive,
  });

  factory EssRecentActivityModel.fromRawJson(String str) =>
      EssRecentActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EssRecentActivityModel.fromJson(Map<String, dynamic> json) =>
      EssRecentActivityModel(
        icon: json["icon"],
        caption: json["caption"],
        subheading: json["subheading"],
        info1: json["info1"],
        info2: json["info2"],
        isactive: json["isactive"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "caption": caption,
        "subheading": subheading,
        "info1": info1,
        "info2": info2,
        "isactive": isactive,
      };
}
