import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/constants/solving_status.dart';

class BookModel {
  late String userKey;
  late String username;
  late List<String> imageDownloadUrls;
  late String bookKey;
  late String bookTitle;
  late String bookDesc;
  late List<String> bookTags;
  late List<String> bookItems;
  late List<String> bookUsers;
  late List<String> numOfLikesBook;
  late List<SolvedUsersAndScore> solvedUsersAndScore;
  late String lastComment;
  late String lastCommentor;
  late DateTime lastCommentTime;
  late int numOfComments;
  late DateTime createDate;
  late String modeOfBook;
  late DocumentReference? reference;

  BookModel({
    required this.userKey,
    required this.username,
    required this.bookKey,
    required this.imageDownloadUrls,
    required this.bookTitle,
    required this.bookDesc,
    required this.bookTags,
    required this.bookItems,
    required this.bookUsers,
    required this.numOfLikesBook,
    required this.solvedUsersAndScore,
    required this.lastComment,
    required this.lastCommentor,
    required this.lastCommentTime,
    required this.numOfComments,
    required this.createDate,
    required this.modeOfBook,
    this.reference,
  });

  BookModel.fromJson(Map<String, dynamic> json, this.bookKey, this.reference) {
    userKey = json[KEY_USERKEY] ?? "";
    username = json[KEY_USERNAME] ?? "";
    bookTitle = json[KEY_BOOKTITLE] ?? "";
    imageDownloadUrls = json[KEY_IMAGEDOWNLOADURLS] != null ? json[KEY_IMAGEDOWNLOADURLS].cast<String>() : [];
    bookDesc = json[KEY_BOOKDESC] ?? "";
    bookItems = json[KEY_BOOKITEMS] != null ? json[KEY_BOOKITEMS].cast<String>() : [];
    bookUsers = json[KEY_BOOKUSERS] != null ? json[KEY_BOOKUSERS].cast<String>() : [];
    bookTags = json[KEY_BOOKTAGS] != null ? json[KEY_BOOKTAGS].cast<String>() : [];
    numOfLikesBook = json[KEY_NUMOFLIKESBOOK] != null ? json[KEY_NUMOFLIKESBOOK].cast<String>() : [];
    if (json[KEY_SOLVEDUSERSANDSCORE] != null) {
      solvedUsersAndScore = [];
      json[KEY_SOLVEDUSERSANDSCORE].forEach((v) {
        solvedUsersAndScore.add(SolvedUsersAndScore.fromJson(v));
      });
    }
    numOfComments = json[KEY_NUMOFCOMMENTS] != null ? json[KEY_NUMOFCOMMENTS] : 0;
    lastComment = json[KEY_LASTCOMMENT] ?? "";
    lastCommentor = json[KEY_LASTCOMMENTOR] ?? "";
    lastCommentTime = json[KEY_LASTCOMMENTTIME] == null ? DateTime.now().toUtc() : (json[KEY_CREATEDATE] as Timestamp).toDate();
    createDate = json[KEY_CREATEDATE] == null ? DateTime.now().toUtc() : (json[KEY_CREATEDATE] as Timestamp).toDate();
    modeOfBook = json[KEY_MODEOFBOOK] ?? 'normal';
  }
  BookModel.fromAlgoliaObject(Map<String, dynamic> json, this.bookKey) {
    userKey = json[KEY_USERKEY] ?? "";
    username = json[KEY_USERNAME] ?? "";
    bookTitle = json[KEY_BOOKTITLE] ?? "";
    imageDownloadUrls = json[KEY_IMAGEDOWNLOADURLS] != null ? json[KEY_IMAGEDOWNLOADURLS].cast<String>() : [];
    bookDesc = json[KEY_BOOKDESC] ?? "";
    bookItems = json[KEY_BOOKITEMS] != null ? json[KEY_BOOKITEMS].cast<String>() : [];
    bookUsers = json[KEY_BOOKUSERS] != null ? json[KEY_BOOKUSERS].cast<String>() : [];
    bookTags = json[KEY_BOOKTAGS] != null ? json[KEY_BOOKTAGS].cast<String>() : [];
    numOfLikesBook = json[KEY_NUMOFLIKESBOOK] != null ? json[KEY_NUMOFLIKESBOOK].cast<String>() : [];
    if (json[KEY_SOLVEDUSERSANDSCORE] != null) {
      solvedUsersAndScore = [];
      json[KEY_SOLVEDUSERSANDSCORE].forEach((v) {
        solvedUsersAndScore.add(SolvedUsersAndScore.fromJson(v));
      });
    }
    numOfComments = json[KEY_NUMOFCOMMENTS] != null ? json[KEY_NUMOFCOMMENTS] : 0;
    lastComment = json[KEY_LASTCOMMENT] ?? "";
    lastCommentor = json[KEY_LASTCOMMENTOR] ?? "";
    lastCommentTime = DateTime.now().toUtc();
    createDate = DateTime.now().toUtc();
    modeOfBook = json[KEY_MODEOFBOOK] ?? 'normal';
  }

  BookModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        );

  BookModel.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(
          snapshot.data(),
          snapshot.id,
          snapshot.reference,
        );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map[KEY_USERKEY] = userKey;
    map[KEY_USERNAME] = username;
    map[KEY_BOOKTITLE] = bookTitle;
    map[KEY_IMAGEDOWNLOADURLS] = imageDownloadUrls;
    map[KEY_BOOKDESC] = bookDesc;
    map[KEY_BOOKTAGS] = bookTags;
    map[KEY_BOOKITEMS] = bookItems;
    map[KEY_BOOKUSERS] = bookUsers;
    map[KEY_NUMOFLIKESBOOK] = numOfLikesBook;
    if (solvedUsersAndScore != null) {
      map[KEY_SOLVEDUSERSANDSCORE] = solvedUsersAndScore.map((v) => v.toJson()).toList();
    }
    map[KEY_NUMOFCOMMENTS] = numOfComments;
    map[KEY_LASTCOMMENT] = lastComment;
    map[KEY_LASTCOMMENTOR] = lastCommentor;
    map[KEY_LASTCOMMENTTIME] = lastCommentTime;
    map[KEY_CREATEDATE] = createDate;
    map[KEY_MODEOFBOOK] = modeOfBook;
    return map;
  }

  static String generateBookKey(String userKey, String bookTitle, String emailId) {
    String timeInMicro = DateTime.now().microsecondsSinceEpoch.toString();
    return '${userKey}_${timeInMicro}';
  }
}

class SolvedUsersAndScore {
  // late String username;
  late String userKey;
  late int scoreOfBook;
  late int solvingPage;
  late String solvingStatus;

  SolvedUsersAndScore({
    // required this.username,
    required this.userKey,
    required this.scoreOfBook,
    required this.solvingPage,
    required this.solvingStatus,
  });

  SolvedUsersAndScore.fromJson(Map<String, dynamic> json) {
    // username = json[KEY_USERNAME] ?? '';
    userKey = json[KEY_USERKEY] ?? '';
    scoreOfBook = json[KEY_SCOREOFBOOK] ?? 0;
    solvingPage = json[KEY_SOLVINGPAGE] ?? 0;
    solvingStatus = json[KEY_SOLVINGSTATUS] ?? SolvingStatus.notYet.code;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    // map[KEY_USERNAME] = username;
    map[KEY_USERKEY] = userKey;
    map[KEY_SCOREOFBOOK] = scoreOfBook;
    map[KEY_SOLVINGPAGE] = solvingPage;
    map[KEY_SOLVINGSTATUS] = solvingStatus;
    return map;
  }
}
