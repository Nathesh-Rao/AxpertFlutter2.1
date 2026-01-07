/// applogo : ""
/// appcolor : "#000000"
/// modifiedontime : ""
/// enablecitizenusers : false
/// enablegeofencing : false
/// enablegeotagging : false
/// enablefingerprint : false
/// enablefacialrecognition : false
/// enableforceLogin : false
/// days : ""

class SigninDetailsModel {
  SigninDetailsModel({
    this.applogo,
    this.appcolor,
    this.modifiedontime,
    this.enablecitizenusers,
    this.enablegeofencing,
    this.enablegeotagging,
    this.enablefingerprint,
    this.enablefacialrecognition,
    this.enableforceLogin,
    this.days,
  });

  SigninDetailsModel.fromJson(dynamic json) {
    applogo = json['applogo'];
    appcolor = json['appcolor'];
    modifiedontime = json['modifiedontime'];
    enablecitizenusers = json['enablecitizenusers'] ?? false;
    enablegeofencing = json['enablegeofencing'] ?? false;
    enablegeotagging = json['enablegeotagging'] ?? false;
    enablefingerprint = json['enablefingerprint'] ?? false;
    enablefacialrecognition = json['enablefacialrecognition'] ?? false;
    enableforceLogin = json['enableforceLogin'] ?? false;
    days = json['days'];
  }

  String? applogo;
  String? appcolor;
  String? modifiedontime;
  bool? enablecitizenusers;
  bool? enablegeofencing;
  bool? enablegeotagging;
  bool? enablefingerprint;
  bool? enablefacialrecognition;
  bool? enableforceLogin;
  String? days;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['applogo'] = applogo;
    map['appcolor'] = appcolor;
    map['modifiedontime'] = modifiedontime;
    map['enablecitizenusers'] = enablecitizenusers;
    map['enablegeofencing'] = enablegeofencing;
    map['enablegeotagging'] = enablegeotagging;
    map['enablefingerprint'] = enablefingerprint;
    map['enablefacialrecognition'] = enablefacialrecognition;
    map['enableforceLogin'] = enableforceLogin;
    map['days'] = days;
    return map;
  }
}
