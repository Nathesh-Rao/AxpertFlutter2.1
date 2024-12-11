import 'dart:convert';

class EssAnnouncementModel {
  final String imageurl;
  final String caption;
  final String subheading;
  final String description;
  final String announcementlink;
  final String pageid;

  EssAnnouncementModel({
    required this.imageurl,
    required this.caption,
    required this.subheading,
    required this.description,
    required this.announcementlink,
    required this.pageid,
  });

  factory EssAnnouncementModel.fromRawJson(String str) =>
      EssAnnouncementModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EssAnnouncementModel.fromJson(Map<String, dynamic> json) =>
      EssAnnouncementModel(
        imageurl: json["imageurl"],
        caption: json["caption"],
        subheading: json["subheading"],
        description: json["description"],
        announcementlink: json["announcementlink"],
        pageid: json["pageid"],
      );

  Map<String, dynamic> toJson() => {
        "imageurl": imageurl,
        "caption": caption,
        "subheading": subheading,
        "description": description,
        "announcementlink": announcementlink,
        "pageid": pageid,
      };
}
