class TagNotification {
  List<Logs>? logs;
  int? currentPage;
  int? showNumber;

  TagNotification({this.logs, this.currentPage, this.showNumber});

  TagNotification.fromJson(Map<String, dynamic> json) {
    if (json['logs'] != null) {
      logs = <Logs>[];
      json['logs'].forEach((v) {
        logs!.add(Logs.fromJson(v));
      });
    }
    currentPage = json['currentPage'];
    showNumber = json['showNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.logs != null) {
      data['logs'] = this.logs!.map((v) => v.toJson()).toList();
    }
    data['currentPage'] = this.currentPage;
    data['showNumber'] = this.showNumber;
    return data;
  }
}

class Logs {
  List<String>? userList;
  List<String>? tagList;
  List<String>? groupList;
  String? content;
  int? sendTime;

  Logs(
      {this.userList,
      this.tagList,
      this.groupList,
      this.content,
      this.sendTime});

  Logs.fromJson(Map<String, dynamic> json) {
    userList = json['userList'].cast<String>();
    tagList = json['tagList'].cast<String>();
    groupList = json['groupList'].cast<String>();
    content = json['content'];
    sendTime = json['sendTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userList'] = this.userList;
    data['tagList'] = this.tagList;
    data['groupList'] = this.groupList;
    data['content'] = this.content;
    data['sendTime'] = this.sendTime;
    return data;
  }
}
