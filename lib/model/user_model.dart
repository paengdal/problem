import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';

class UserModel {
  late String userKey;
  late String profileImg;
  late List<dynamic> imageDownloadUrls;
  late String email;
  late String token;
  late List<dynamic> myItems;
  late int numOfFollowers;
  late List<dynamic> likedItems;
  late List<dynamic> solvedItems;
  late String username;
  late List<dynamic> followings;
  late List<dynamic> myBooks;
  late List<dynamic> likedBooks;
  late List<SolvedBooksAndScore> solvedBooksAndScore;
  late DateTime createDate;
  late DocumentReference? reference;

  UserModel({
    required this.userKey,
    required this.profileImg,
    required this.imageDownloadUrls,
    required this.email,
    required this.token,
    required this.myItems,
    required this.numOfFollowers,
    required this.likedItems,
    required this.solvedItems,
    required this.username,
    required this.followings,
    required this.myBooks,
    required this.likedBooks,
    required this.solvedBooksAndScore,
    required this.createDate,
    this.reference,
  });

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, this.reference) {
    profileImg = map[KEY_PROFILEIMG];
    imageDownloadUrls = map[KEY_IMAGEDOWNLOADURLS];
    username = map[KEY_USERNAME];
    email = map[KEY_EMAIL];
    token = map[KEY_TOKEN];
    likedItems = map[KEY_LIKEDITEMS];
    solvedItems = map[KEY_SOLVEDITEMS];
    numOfFollowers = map[KEY_NUMOFFOLLOWERS];
    followings = map[KEY_FOLLOWINGS];
    myItems = map[KEY_MYITEMS];
    myBooks = map[KEY_MYBOOKS];
    likedBooks = map[KEY_LIKEDBOOKS];
    if (map[KEY_SOLVEDBOOKSANDSCORE] != null) {
      solvedBooksAndScore = [];
      map[KEY_SOLVEDBOOKSANDSCORE].forEach((v) {
        solvedBooksAndScore.add(SolvedBooksAndScore.fromJson(v));
      });
    }
    createDate = map[KEY_CREATEDATE] == null ? DateTime.now().toUtc() : (map[KEY_CREATEDATE] as Timestamp).toDate();
  }

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        );

  UserModel.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(
          snapshot.data(),
          snapshot.id,
          snapshot.reference,
        );

  static Map<String, dynamic> getMapForCreateUser(String email, String username) {
    Map<String, dynamic> map = Map();
    map[KEY_PROFILEIMG] = "";
    map[KEY_IMAGEDOWNLOADURLS] = [];
    // map[KEY_USERNAME] = email.split("@")[0];
    map[KEY_USERNAME] = username;
    map[KEY_EMAIL] = email;
    map[KEY_TOKEN] = "";
    map[KEY_LIKEDITEMS] = [];
    map[KEY_SOLVEDITEMS] = [];
    map[KEY_NUMOFFOLLOWERS] = 0;
    map[KEY_FOLLOWINGS] = [];
    map[KEY_MYITEMS] = [];
    map[KEY_MYBOOKS] = [];
    map[KEY_LIKEDBOOKS] = [];
    map[KEY_SOLVEDBOOKSANDSCORE] = [];
    map[KEY_CREATEDATE] = DateTime.now().toUtc();
    return map;
  }
}

class SolvedBooksAndScore {
  late String bookKey;
  late int scoreOfBook;
  late int solvingPage;
  late String solvingStatus;

  SolvedBooksAndScore({
    required this.bookKey,
    required this.scoreOfBook,
    required this.solvingPage,
    required this.solvingStatus,
  });

  SolvedBooksAndScore.fromJson(Map<String, dynamic> json) {
    bookKey = json[KEY_BOOKKEY] ?? '';
    scoreOfBook = json[KEY_SCOREOFBOOK] ?? 0;
    solvingPage = json[KEY_SOLVINGPAGE] ?? 0;
    solvingStatus = json[KEY_SOLVINGSTATUS] ?? 'notYet';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map[KEY_BOOKKEY] = bookKey;
    map[KEY_SCOREOFBOOK] = scoreOfBook;
    map[KEY_SOLVINGPAGE] = solvingPage;
    map[KEY_SOLVINGSTATUS] = solvingStatus;
    return map;
  }
}
