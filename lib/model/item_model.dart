import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';

class ItemModel {
  late String itemKey;
  late String userKey;
  late String username;
  late List<String> imageDownloadUrls;
  late String category;
  late String question;
  late String answer;
  late String hint;
  late List<String> options;
  late List<dynamic> numOfLikes;
  late List<dynamic> solvedUsers;
  // late String lastComment;
  // late String lastCommentor;
  // late DateTime lastCommentTime;
  late int numOfComments;
  late DateTime createDate;
  late DocumentReference? reference;

  ItemModel({
    required this.itemKey,
    required this.userKey,
    required this.username,
    required this.imageDownloadUrls,
    required this.category,
    required this.question,
    required this.answer,
    required this.hint,
    required this.options,
    required this.numOfLikes,
    required this.solvedUsers,
    // required this.lastComment,
    // required this.lastCommentor,
    // required this.lastCommentTime,
    required this.numOfComments,
    required this.createDate,
    this.reference,
  });

  ItemModel.fromJson(Map<String, dynamic> json, this.itemKey, this.reference) {
    userKey = json[KEY_USERKEY] ?? "";
    username = json[KEY_USERNAME] ?? "";
    imageDownloadUrls = json[KEY_IMAGEDOWNLOADURLS] != null ? json[KEY_IMAGEDOWNLOADURLS].cast<String>() : [];
    category = json[KEY_CATEGORY] ?? "none";
    question = json[KEY_QUESTION] ?? "";
    answer = json[KEY_ANSWER] ?? "";
    hint = json[KEY_HINT] ?? "";
    options = json[KEY_OPTIONS] != null ? json[KEY_OPTIONS].cast<String>() : [];
    numOfLikes = json[KEY_NUMOFLIKES] != null ? json[KEY_NUMOFLIKES] : [];
    solvedUsers = json[KEY_SOLVEDUSERS] != null ? json[KEY_SOLVEDUSERS] : [];
    numOfComments = json[KEY_NUMOFCOMMENTS] != null ? json[KEY_NUMOFCOMMENTS] : 0;
    // lastComment = json[KEY_LASTCOMMENT] ?? "";
    // lastCommentor = json[KEY_LASTCOMMENTOR] ?? "";
    // lastCommentTime = json[KEY_LASTCOMMENTTIME] == null ? DateTime.now().toUtc() : (json[KEY_LASTCOMMENTTIME] as Timestamp).toDate();
    createDate = json[KEY_CREATEDATE] == null ? DateTime.now().toUtc() : (json[KEY_CREATEDATE] as Timestamp).toDate();
  }

  ItemModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        );

  ItemModel.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(
          snapshot.data(),
          snapshot.id,
          snapshot.reference,
        );

// firebase로 보낼때 사용
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map[KEY_USERKEY] = userKey;
    map[KEY_USERNAME] = username;
    map[KEY_IMAGEDOWNLOADURLS] = imageDownloadUrls;
    map[KEY_CATEGORY] = category;
    map[KEY_QUESTION] = question;
    map[KEY_ANSWER] = answer;
    map[KEY_HINT] = hint;
    map[KEY_OPTIONS] = options;
    map[KEY_NUMOFLIKES] = numOfLikes;
    map[KEY_SOLVEDUSERS] = solvedUsers;
    map[KEY_NUMOFCOMMENTS] = numOfComments;
    // map[KEY_LASTCOMMENT] = lastComment;
    // map[KEY_LASTCOMMENTOR] = lastCommentor;
    // map[KEY_LASTCOMMENTTIME] = lastCommentTime;
    map[KEY_CREATEDATE] = createDate;
    return map;
  }

  static String generateItemKey(String uid) {
    String timeInMilli = DateTime.now().millisecondsSinceEpoch.toString();
    return '${uid}_$timeInMilli';
  }
}
