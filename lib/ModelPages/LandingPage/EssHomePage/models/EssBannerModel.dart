import 'dart:convert';

class EssBannerModel {
  final String icon;
  final String smallheading;
  final String caption;
  final String action1Icon;
  final String action2Icon;
  final String action3Icon;
  final String action1Url;
  final String action2Url;
  final String action3Url;

  EssBannerModel({
    required this.icon,
    required this.smallheading,
    required this.caption,
    required this.action1Icon,
    required this.action2Icon,
    required this.action3Icon,
    required this.action1Url,
    required this.action2Url,
    required this.action3Url,
  });

  factory EssBannerModel.fromRawJson(String str) =>
      EssBannerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EssBannerModel.fromJson(Map<String, dynamic> json) => EssBannerModel(
        icon: json["icon"],
        smallheading: json["smallheading"],
        caption: json["caption"],
        action1Icon: json["action1icon"],
        action2Icon: json["action2icon"],
        action3Icon: json["action3icon"],
        action1Url: json["action1url"],
        action2Url: json["action2url"],
        action3Url: json["action3url"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "smallheading": smallheading,
        "caption": caption,
        "action1icon": action1Icon,
        "action2icon": action2Icon,
        "action3icon": action3Icon,
        "action1url": action1Url,
        "action2url": action2Url,
        "action3url": action3Url,
      };
}
