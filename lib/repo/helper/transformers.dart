import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/comment_reply_model.dart';
import 'package:quiz_first/model/user_model.dart';

class Transformers {
  final toUser = StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
      UserModel>.fromHandlers(
    handleData: (snapshot, sink) async {
      // 고민: 왜 async하는건지?
      sink.add(UserModel.fromSnapshot(snapshot));
    },
  );

  // 모든 유저 리스트
  final toUsers = StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
      List<UserModel>>.fromHandlers(
    handleData: (snapshot, sink) async {
      List<UserModel> users = [];
      snapshot.docs.forEach((documentSnapshot) {
        UserModel userModel = UserModel.fromSnapshot(documentSnapshot);
        users.add(userModel);
      });
      sink.add(users);
    },
  );

  // 모든 유저의 likedItems Key리스트
  final toUsersLikedItemKeys = StreamTransformer<
      QuerySnapshot<Map<String, dynamic>>, List<dynamic>>.fromHandlers(
    handleData: (snapshot, sink) async {
      var likedItems = [];
      snapshot.docs.forEach((documentSnapshot) {
        UserModel userModel = UserModel.fromSnapshot(documentSnapshot);
        likedItems.addAll(userModel.likedItems);
      });
      sink.add(likedItems);
    },
  );
  // 모든 유저의 likedBooks Key리스트
  final toUsersLikedBookKeys = StreamTransformer<
      QuerySnapshot<Map<String, dynamic>>, List<dynamic>>.fromHandlers(
    handleData: (snapshot, sink) async {
      var likedBooks = [];
      snapshot.docs.forEach((documentSnapshot) {
        UserModel userModel = UserModel.fromSnapshot(documentSnapshot);
        likedBooks.addAll(userModel.likedBooks);
      });
      sink.add(likedBooks);
    },
  );

  // 나를 제외한 모든 유저 리스트
  final toUsersExceptMe = StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
      List<UserModel>>.fromHandlers(
    handleData: (snapshot, sink) async {
      List<UserModel> users = [];

      User _user = await FirebaseAuth.instance.currentUser!;

      snapshot.docs.forEach((documentSnapshot) {
        if (_user.uid != documentSnapshot.id) {
          UserModel userModel = UserModel.fromSnapshot(documentSnapshot);
          users.add(userModel);
        }
      });
      sink.add(users);
    },
  );

  // 모든 커멘트
  final toComments = StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
      List<CommentModel>>.fromHandlers(
    handleData: (snapshot, sink) async {
      List<CommentModel> comments = [];
      snapshot.docs.forEach((documentSnapshot) {
        comments.add(CommentModel.fromSnapshot(documentSnapshot));
      });
      sink.add(comments);
    },
  );

  // 모든 커멘트 답글
  final toCommentReplies = StreamTransformer<
      QuerySnapshot<Map<String, dynamic>>,
      List<CommentReplyModel>>.fromHandlers(
    handleData: (snapshot, sink) async {
      List<CommentReplyModel> commentReplies = [];
      snapshot.docs.forEach((documentSnapshot) {
        commentReplies.add(CommentReplyModel.fromSnapshot(documentSnapshot));
      });
      sink.add(commentReplies);
    },
  );
}
