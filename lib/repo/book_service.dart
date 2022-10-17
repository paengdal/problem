import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/constants/solving_status.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/helper/transformers.dart';
import 'package:quiz_first/repo/image_storage.dart';

class BookService {
  static final BookService _itemService = BookService._internal();
  factory BookService() => _itemService;
  BookService._internal();

  // Book(문제집) 만들기
  Future createNewBook(Map<String, dynamic> json, String userKey, String bookKey) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot userSnapshot = await userRef.get();
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      if (userSnapshot.exists) {
        await transaction.set(bookRef, json);

        await transaction.update(userRef, {
          KEY_MYBOOKS: FieldValue.arrayUnion([bookKey]),
        });
      }
    });
  }

  // Book(문제집) 만들기 - json파일의 데이터를 이용
  Future createNewBooksByJsonFile() async {
    var response = await http.get(Uri.parse('https://paengdal.github.io/json/test.json'));
    var responseByDecoding = jsonDecode(response.body);

    List<Map<String, dynamic>> jsonData = [];
    for (int i = 0; i < responseByDecoding.length; i++) {
      var temp = responseByDecoding[i];
      jsonData.add(temp);
    }

    for (int i = 0; i < jsonData.length; i++) {
      final DocumentReference testRef = FirebaseFirestore.instance.collection('Test').doc();
      testRef.set(jsonData[i]);
    }
  }

  // 특정 bookKey의 문제집만 가져오기
  Future<BookModel> getBookByBookKey(String bookKey) async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];

    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookModel.bookKey == bookKey) {
        books.add(bookModel);
      }
    }

    return books[0];
  }

  // 특정 bookKey의 문제집들만 가져오기
  Future<List<BookModel>> getBooksByBookKeys(bookKeys) async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];

    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookKeys.contains(bookModel.bookKey)) {
        books.add(bookModel);
      }
    }

    return books;
  }

  // 모든 문제집 가져오기
  Future<List<BookModel>> getAllBooks() async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];
    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      books.add(bookModel);
    }

    return books;
  }

  // 모든 문제집 가져오기 - 관리자가 만든 문제 제외
  Future<List<BookModel>> getAllBooksExceptByAdmin() async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];
    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookModel.userKey != 'vD3muzjYSmUyvkZzpzuFNBCy67t2') {
        books.add(bookModel);
      }
    }

    return books;
  }

  // 내가 만든 문제집 가져오기
  Future<List<BookModel>> getMyBooks(String userKey) async {
    CollectionReference<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];
    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookModel.userKey == userKey) {
        books.add(bookModel);
      }
    }

    return books;
  }

  // 관리자가 만든 문제집 가져오기(공지?)
  Future<List<BookModel>> getAdminBooks() async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collection(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];
    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookModel.userKey == 'vD3muzjYSmUyvkZzpzuFNBCy67t2') books.add(bookModel);
    }

    return books;
  }

  // 문제가 없는 문제집 제외하고 가져오기
  Future<List<BookModel>> getBooksExcetpEmpty() async {
    Query<Map<String, dynamic>> booksRef = FirebaseFirestore.instance.collectionGroup(COL_BOOKS);
    QuerySnapshot<Map<String, dynamic>> booksSnapshot = await booksRef.get();

    List<BookModel> books = [];
    for (int i = 0; i < booksSnapshot.size; i++) {
      BookModel bookModel = BookModel.fromQuerySnapshot(booksSnapshot.docs[i]);
      if (bookModel.bookItems.isNotEmpty) {
        books.add(bookModel);
      }
    }

    return books;
  }

  // 문제집 삭제하기
  void deleteBook(List<BookModel> bookModels, BookModel bookModel, index, String userKey) async {
    if (bookModel.imageDownloadUrls.isNotEmpty) {
      // - 이미지가 있는 경우에만 Storage 삭제 실행
      ImageStorage.deleteImages(bookModel.bookKey);

      // - 해당 Book 삭제
      final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookModel.bookKey);
      bookRef.delete();

      // - myBooks에서 해당 bookKey삭제
      final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
      final DocumentSnapshot userSnapshot = await userRef.get();
      var userSnapshotMap = userSnapshot.data() as Map;
      List<dynamic> myBooks = userSnapshotMap[KEY_MYBOOKS];
      myBooks.remove(bookModel.bookKey);
      userRef.update({KEY_MYBOOKS: myBooks});

      // likedBooks, solvedBooks에서도 해당 bookKey 삭제 필요. 단 모든 user의 likedBooks 불러와서 삭제해야할듯.
      // comments collection 삭제(collection은 삭제 불가, 나중에 다시 시도 예정 - 개별 comment들을 for문으로?)

      // - 피드에서 해당 목록 삭제
      bookModels.removeAt(index);
    } else {
      // - 해당 Book 삭제
      final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookModel.bookKey);
      bookRef.delete();

      // - myBooks에서 해당 bookKey삭제
      final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
      final DocumentSnapshot userSnapshot = await userRef.get();
      var userSnapshotMap = userSnapshot.data() as Map;
      List<dynamic> myBooks = userSnapshotMap[KEY_MYBOOKS];
      myBooks.remove(bookModel.bookKey);
      userRef.update({KEY_MYBOOKS: myBooks});

      // likedBooks, solvedBooks에서도 해당 bookKey 삭제 필요. 단 모든 user의 likedBooks 불러와서 삭제해야할듯.
      // comments collection 삭제(collection은 삭제 불가, 나중에 다시 시도 예정 - 개별 comment들을 for문으로?)

      // - 피드에서 해당 목록 삭제
      bookModels.removeAt(index);

      // 댓글도 같이 지워야 완전히 삭제가 되는지?
      // 유저의 myitems리스트 지워야함
    }
  }

  // 풀던 문제(페이지) 번호 저장하기
  Future<void> saveSolvingPage(String bookKey, String userKeyOfSolver, int solvingPage, int score, String solvingStatus) async {
    // - book의 solved_users_and_score에 solvingPage 변경
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    final DocumentSnapshot bookSnapshot = await bookRef.get();

    var bookModel = bookSnapshot.data() as Map;
    List<dynamic> solvedUsersAndScoreList = bookModel[KEY_SOLVEDUSERSANDSCORE] ?? [];

    // - 기존 리스트가 비어있는지 확인
    if (solvedUsersAndScoreList.isNotEmpty)
    // - 비어있지 않으면
    {
      int? index;
      for (int i = 0; i < solvedUsersAndScoreList.length; i++) {
        Map<String, dynamic> a = solvedUsersAndScoreList[i] as Map<String, dynamic>;
        if (a[KEY_USERKEY] == userKeyOfSolver) {
          index = i;
        }
      }
      if (index != null) {
        solvedUsersAndScoreList[index][KEY_SOLVINGSTATUS] = solvingStatus;
        solvedUsersAndScoreList[index][KEY_SOLVINGPAGE] = solvingPage;
      } else {
        solvedUsersAndScoreList.add({KEY_USERKEY: userKeyOfSolver, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.solving.code, KEY_SOLVINGPAGE: solvingPage});
      }
      bookRef.update({KEY_SOLVEDUSERSANDSCORE: solvedUsersAndScoreList});
    }
    // - 비어있으면
    else {
      solvedUsersAndScoreList.add({KEY_USERKEY: userKeyOfSolver, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.solving.code, KEY_SOLVINGPAGE: solvingPage});
      bookRef.update({KEY_SOLVEDUSERSANDSCORE: solvedUsersAndScoreList});
    }

    // - 문제를 푼 user의 solved_books_and_score에 solvingPage 변경
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKeyOfSolver);
    final DocumentSnapshot userSnapshot = await userRef.get();

    var userModel = userSnapshot.data() as Map;
    List<dynamic> solvedBooksAndScoreList = userModel[KEY_SOLVEDBOOKSANDSCORE] ?? [];

    // - 기존 리스트가 비어있는지 확인
    if (solvedBooksAndScoreList.isNotEmpty)
    // 비어있지 않으면 중복체크 후 추가
    {
      int? index;
      for (int i = 0; i < solvedBooksAndScoreList.length; i++) {
        Map<String, dynamic> a = solvedBooksAndScoreList[i] as Map<String, dynamic>;
        if (a[KEY_BOOKKEY] == bookKey) {
          index = i;
        }
      }
      if (index != null) {
        solvedBooksAndScoreList[index][KEY_SOLVINGSTATUS] = solvingStatus;
        solvedBooksAndScoreList[index][KEY_SOLVINGPAGE] = solvingPage;
      } else {
        solvedBooksAndScoreList.add({KEY_BOOKKEY: bookKey, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.solving.code, KEY_SOLVINGPAGE: solvingPage});
      }

      userRef.update({KEY_SOLVEDBOOKSANDSCORE: solvedBooksAndScoreList});
    }
    // - 비어있으면 그냥 추가
    else {
      solvedBooksAndScoreList.add({KEY_BOOKKEY: bookKey, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.solving.code, KEY_SOLVINGPAGE: solvingPage});
      userRef.update({KEY_SOLVEDBOOKSANDSCORE: solvedBooksAndScoreList});
    }
  }

  // 문제집 풀기를 완료한 경우
  Future<void> doneSolvingBook(String bookKey, String userKeyOfSolver, String userKeyOfMaker, int score) async {
    // - book의 solved_users_and_score에 userKey와 score 추가, solvingStatus 변경
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    final DocumentSnapshot bookSnapshot = await bookRef.get();

    var bookModel = bookSnapshot.data() as Map;
    List<dynamic> solvedUsersAndScoreList = bookModel[KEY_SOLVEDUSERSANDSCORE] ?? [];

    // - 기존 리스트가 비어있는지 확인
    if (solvedUsersAndScoreList.isNotEmpty)
    // - 비어있지 않으면 기존에 푼 문제인지 확인
    {
      int? index;
      for (int i = 0; i < solvedUsersAndScoreList.length; i++) {
        Map<String, dynamic> a = solvedUsersAndScoreList[i] as Map<String, dynamic>;
        if (a[KEY_USERKEY] == userKeyOfSolver) {
          index = i;
        }
      }
      if (index != null) {
        solvedUsersAndScoreList[index][KEY_SOLVINGSTATUS] = SolvingStatus.done.code;
        solvedUsersAndScoreList[index][KEY_SOLVINGPAGE] = 0;
      } else {
        solvedUsersAndScoreList.add({KEY_USERKEY: userKeyOfSolver, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.done.code, KEY_SOLVINGPAGE: 0});
      }

      bookRef.update({KEY_SOLVEDUSERSANDSCORE: solvedUsersAndScoreList});
    }
    // - 비어있으면 그냥 추가
    else {
      solvedUsersAndScoreList.add({KEY_USERKEY: userKeyOfSolver, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.done.code, KEY_SOLVINGPAGE: 0});
      bookRef.update({KEY_SOLVEDUSERSANDSCORE: solvedUsersAndScoreList});
    }

    // - 문제를 푼 user의 solved_books_and_score에 bookKey와 score 추가, solvingStatus 변경
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKeyOfSolver);
    final DocumentSnapshot userSnapshot = await userRef.get();

    var userModel = userSnapshot.data() as Map;
    List<dynamic> solvedBooksAndScoreList = userModel[KEY_SOLVEDBOOKSANDSCORE] ?? [];

    // - 기존 리스트가 비어있는지 확인
    if (solvedBooksAndScoreList.isNotEmpty)
    // 비어있지 않으면 중복체크 후 추가
    {
      int? index;
      for (int i = 0; i < solvedBooksAndScoreList.length; i++) {
        Map<String, dynamic> a = solvedBooksAndScoreList[i] as Map<String, dynamic>;
        if (a[KEY_BOOKKEY] == bookKey) {
          index = i;
        }
      }
      if (index != null) {
        solvedBooksAndScoreList[index][KEY_SOLVINGSTATUS] = SolvingStatus.done.code;
        solvedBooksAndScoreList[index][KEY_SOLVINGPAGE] = 0;
      } else {
        solvedBooksAndScoreList.add({KEY_BOOKKEY: bookKey, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.done.code, KEY_SOLVINGPAGE: 0});
      }

      userRef.update({KEY_SOLVEDBOOKSANDSCORE: solvedBooksAndScoreList});
    }
    // - 비어있으면 그냥 추가
    else {
      solvedBooksAndScoreList.add({KEY_BOOKKEY: bookKey, KEY_SCOREOFBOOK: score, KEY_SOLVINGSTATUS: SolvingStatus.done.code, KEY_SOLVINGPAGE: 0});
      userRef.update({KEY_SOLVEDBOOKSANDSCORE: solvedBooksAndScoreList});
    }
  }

  // 문제집 수정하기
  Future<void> modifyBook(String bookKey, String bookTitle, String bookDesc) async {
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    await bookRef.update({
      KEY_BOOKTITLE: bookTitle,
      KEY_BOOKDESC: bookDesc,
      // KEY_BOOKTAGS: bookTags,
      // KEY_BOOKUSERS: bookUsers,
      // KEY_IMAGEDOWNLOADURLS: downloadUrls,
      // KEY_BOOKITEMS: bookItems,
      // KEY_CREATEDATE: DateTime.now().toUtc(),
    });
  }

  Future<void> toggleLikeToBookData(String userKey, String bookKey) async {
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    final DocumentSnapshot bookSnapshot = await bookRef.get();
    var bookSnapshotMap = bookSnapshot.data() as Map;
    List<dynamic> snapshotUserKeys = bookSnapshotMap[KEY_NUMOFLIKESBOOK];

    if (bookSnapshot.exists) {
      if (snapshotUserKeys.contains(userKey)) {
        bookRef.update({
          KEY_NUMOFLIKESBOOK: FieldValue.arrayRemove([userKey])
        });
      } else {
        bookRef.update({
          KEY_NUMOFLIKESBOOK: FieldValue.arrayUnion([userKey])
        });
      }
    }
  }
}
