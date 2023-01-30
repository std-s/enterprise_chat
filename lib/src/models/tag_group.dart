class TagGroup {
  List<TagInfo>? tags;

  TagGroup({this.tags});

  TagGroup.fromJson(Map<String, dynamic> json) {
    if (json['tags'] != null) {
      tags = <TagInfo>[];
      json['tags'].forEach((v) {
        tags!.add(TagInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TagInfo {
  String? tagID;
  String? tagName;
  List<TagUserInfo>? userList;

  TagInfo({this.tagID, this.tagName, this.userList});

  TagInfo.fromJson(Map<String, dynamic> json) {
    tagID = json['tagID'];
    tagName = json['tagName'];
    if (json['userList'] != null) {
      userList = <TagUserInfo>[];
      json['userList'].forEach((v) {
        userList!.add(TagUserInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['tagID'] = this.tagID;
    data['tagName'] = this.tagName;
    if (this.userList != null) {
      data['userList'] = this.userList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TagUserInfo {
  String? userID;
  String? userName;

  TagUserInfo({this.userID, this.userName});

  TagUserInfo.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['userID'] = this.userID;
    data['userName'] = this.userName;
    return data;
  }
}
