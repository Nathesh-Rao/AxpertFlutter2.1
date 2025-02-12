import 'dart:convert';

class EssAnnouncementModel {
  final String imageurl;
  final String title;
  final String subtitle;
  final String description;
  final String linkcaption;
  final String pageid;
  final String isactive;

  EssAnnouncementModel({
    required this.imageurl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.linkcaption,
    required this.pageid,
    required this.isactive,
  });

  factory EssAnnouncementModel.fromRawJson(String str) =>
      EssAnnouncementModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EssAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      EssAnnouncementModel(
        imageurl: json["imageurl"],
        title: json["title"],
        subtitle: json["subtitle"],
        description: json["description"],
        linkcaption: json["linkcaption"],
        pageid: json["pageid"],
        isactive: json["isactive"],
      );

  Map<String, dynamic> toJson() => {
        "imageurl": imageurl,
        "title": title,
        "subtitle": subtitle,
        "description": description,
        "linkcaption": linkcaption,
        "pageid": pageid,
        "isactive": isactive,
      };
}
