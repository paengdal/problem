import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/repo/helper/transformers.dart';

import '../model/user_model.dart';

class UserNetworkRepository with Transformers {
  // 새로운 user 만들기(회원가입)
  Future attemptCreateUser({required String userKey, required String email, required String username}) async {
    // 고민 : Future를 꼭 넣어야하는가?
    DocumentReference<Map<String, dynamic>> documentReference = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);

    final DocumentSnapshot documentSnapshot = await documentReference.get();

    if (!documentSnapshot.exists) {
      await documentReference.set(UserModel.getMapForCreateUser(email, username));
    }
  }

  // 특정 user 불러오기
  Stream<UserModel> getUserModelStream(String userKey) {
    return FirebaseFirestore.instance.collection(COL_USERS).doc(userKey).snapshots().transform(toUser);
  }

  // 모든 users 불러오기
  Stream<List<UserModel>> getAllUsersStream() {
    return FirebaseFirestore.instance.collection(COL_USERS).snapshots().transform(toUsers);
  }

  //
  Stream<List<dynamic>> getAllUsersLikedItemKeysStream() {
    return FirebaseFirestore.instance.collection(COL_USERS).snapshots().transform(toUsersLikedItemKeys);
  }

  Stream<List<dynamic>> getAllUsersLikedBookKeysStream() {
    return FirebaseFirestore.instance.collection(COL_USERS).snapshots().transform(toUsersLikedBookKeys);
  }

  Stream<List<UserModel>> getAllUsersExceptMeStream() {
    return FirebaseFirestore.instance.collection(COL_USERS).snapshots().transform(toUsersExceptMe);
  }

  Future<List<String>> getUsersTokensExceptMe(String userKey) async {
    CollectionReference<Map<String, dynamic>> userColRef = FirebaseFirestore.instance.collection(COL_USERS);
    final QuerySnapshot<Map<String, dynamic>> userColSnapshot = await userColRef.get();

    List<String> userTokens = [];

    for (int i = 0; i < userColSnapshot.size; i++) {
      UserModel userModel = UserModel.fromQuerySnapshot(userColSnapshot.docs[i]);
      var token = userModel.token;
      if (token != null &&
          token.isNotEmpty &&
          !userTokens.contains(token) && // 중복 제거
          userModel.userKey != userKey) {
        // 나를 제외
        userTokens.add(token);
      }
    }

    return userTokens;
  }

  Future<UserModel> getUserModel({required String userKey}) async {
    DocumentReference<Map<String, dynamic>> documentReference = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();
    UserModel userModel = UserModel.fromSnapshot(documentSnapshot);
    return userModel;
  }

  // userKey로 특정 몇명의 users 가져오기
  Future<List<UserModel>> getSomeUsersByUserKeys(List<String> userKeys) async {
    CollectionReference<Map<String, dynamic>> usersRef = FirebaseFirestore.instance.collection(COL_USERS);
    QuerySnapshot<Map<String, dynamic>> usersSnapshot = await usersRef.get();

    List<UserModel> users = [];

    for (int i = 0; i < usersSnapshot.size; i++) {
      UserModel userModel = UserModel.fromQuerySnapshot(usersSnapshot.docs[i]);
      if (userKeys.contains(userModel.userKey)) {
        users.add(userModel);
      }
    }

    return users;
  }

  Future<void> toggleLikeToUserDataOfItem(String userKey, String itemKey) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var userSnapshotMap = userSnapshot.data() as Map;
    List<dynamic> snapshotItemKeys = userSnapshotMap[KEY_LIKEDITEMS];

    if (userSnapshot.exists) {
      if (snapshotItemKeys.contains(itemKey)) {
        userRef.update({
          KEY_LIKEDITEMS: FieldValue.arrayRemove([itemKey])
        });
      } else {
        userRef.update({
          KEY_LIKEDITEMS: FieldValue.arrayUnion([itemKey])
        });
      }
    }
  }

  Future<void> toggleLikeToUserDataOfBook(String userKey, String bookKey) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(COL_USERS).doc(userKey);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var userSnapshotMap = userSnapshot.data() as Map;
    List<dynamic> snapshotBookKeys = userSnapshotMap[KEY_LIKEDBOOKS];

    if (userSnapshot.exists) {
      if (snapshotBookKeys.contains(bookKey)) {
        userRef.update({
          KEY_LIKEDBOOKS: FieldValue.arrayRemove([bookKey])
        });
      } else {
        userRef.update({
          KEY_LIKEDBOOKS: FieldValue.arrayUnion([bookKey])
        });
      }
    }
  }

  Future<void> addToken({required String userKey, required String token}) async {
    await FirebaseFirestore.instance.collection(COL_USERS).doc(userKey).update({KEY_TOKEN: token});
  }

  Future<void> editProfile(String userKey, String username, List<dynamic> downloadUrls) async {
    await FirebaseFirestore.instance.collection(COL_USERS).doc(userKey).update({KEY_USERNAME: username, KEY_IMAGEDOWNLOADURLS: downloadUrls});
  }
}

UserNetworkRepository userNetworkRepository = UserNetworkRepository();
