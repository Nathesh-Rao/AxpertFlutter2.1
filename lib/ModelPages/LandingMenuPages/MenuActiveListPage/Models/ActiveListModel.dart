class ActiveListModel {
  String? touser;
  String? processname;
  String? taskname;
  String? taskid;
  String? tasktype;
  String? eventdatetime;
  String? fromuser;
  String? displayicon;
  String? displaytitle;
  String? displaycontent;
  String? displaybuttons;
  String? keyfield;
  String? keyvalue;
  String? transid;
  double? recordid;
  String? rectype;
  String? msgtype;
  String? returnable;
  String? displaysubtitle;
  String? allowsend;
  String? allowsendflg;

  ActiveListModel({
    this.touser,
    this.processname,
    this.taskname,
    this.taskid,
    this.tasktype,
    this.eventdatetime,
    this.fromuser,
    this.displayicon,
    this.displaytitle,
    this.displaycontent,
    this.displaybuttons,
    this.keyfield,
    this.keyvalue,
    this.transid,
    this.recordid,
    this.rectype,
    this.msgtype,
    this.returnable,
    this.displaysubtitle,
    this.allowsend,
    this.allowsendflg,
  });

  ActiveListModel.fromJson(dynamic json) {
    touser = json['touser'];
    processname = json['processname'];
    taskname = json['taskname'];
    taskid = json['taskid'];
    tasktype = json['tasktype'];
    eventdatetime = json['eventdatetime'];
    fromuser = json['fromuser'];
    displayicon = json['displayicon'];
    displaytitle = json['displaytitle'];
    displaycontent = json['displaycontent'];
    displaybuttons = json['displaybuttons'];
    keyfield = json['keyfield'];
    keyvalue = json['keyvalue'];
    transid = json['transid'];
    recordid = json['recordid'];
    rectype = json['rectype'];
    msgtype = json['msgtype'];
    returnable = json['returnable'];
    displaysubtitle = json['displaysubtitle'];
    allowsend = json['allowsend'];
    allowsendflg = json['allowsendflg'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['touser'] = touser;
    map['processname'] = processname;
    map['taskname'] = taskname;
    map['taskid'] = taskid;
    map['tasktype'] = tasktype;
    map['eventdatetime'] = eventdatetime;
    map['fromuser'] = fromuser;
    map['displayicon'] = displayicon;
    map['displaytitle'] = displaytitle;
    map['displaycontent'] = displaycontent;
    map['displaybuttons'] = displaybuttons;
    map['keyfield'] = keyfield;
    map['keyvalue'] = keyvalue;
    map['transid'] = transid;
    map['recordid'] = recordid;
    map['rectype'] = rectype;
    map['msgtype'] = msgtype;
    map['returnable'] = returnable;
    map['displaysubtitle'] = displaysubtitle;
    map['allowsend'] = allowsend;
    map['allowsendflg'] = allowsendflg;
    return map;
  }
}
