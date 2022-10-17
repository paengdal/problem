import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/helper/transformers.dart';

import '../model/comment_reply_model.dart';

class CommentNetworkRepository with Transformers {
  Future<void> createNewComment(String bookKey, Map<String, dynamic> commentData) async {
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    final DocumentSnapshot bookSnapshot = await bookRef.get();
    final DocumentReference commentRef = bookRef.collection(COL_COMMENTS).doc();

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      if (bookSnapshot.exists) {
        await transaction.set(commentRef, commentData);

        var numOfCommentsData = bookSnapshot.data() as Map;
        int numOfComments = numOfCommentsData[KEY_NUMOFCOMMENTS];
        await transaction.update(bookRef, {
          KEY_NUMOFCOMMENTS: numOfComments + 1,
          KEY_LASTCOMMENT: commentData[KEY_COMMENT],
          KEY_LASTCOMMENTOR: commentData[KEY_USERNAME],
          KEY_LASTCOMMENTTIME: commentData[KEY_COMMENTTIME],
        });
      }
    });
  }

  Future<void> createNewCommentReply(String bookKey, Map<String, dynamic> commentReplyData, String commentKey) async {
    final DocumentReference bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    // final DocumentSnapshot bookSnapshot = await bookRef.get();
    final DocumentReference commentRef = bookRef.collection(COL_COMMENTS).doc(commentKey);
    final DocumentReference commentReplyRef = commentRef.collection(COL_COMMENTREPLY).doc();
    final DocumentSnapshot bookSnapshot = await bookRef.get();
    final DocumentSnapshot commentSnapshop = await commentRef.get();

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      if (commentSnapshop.exists) {
        await transaction.set(commentReplyRef, commentReplyData);

        var numOfCommentRepliesData = commentSnapshop.data() as Map;
        int numOfCommentReplies = numOfCommentRepliesData[KEY_NUMOFCOMMENTREPLIES];
        await transaction.update(commentRef, {
          KEY_NUMOFCOMMENTREPLIES: numOfCommentReplies + 1,
          // KEY_LASTCOMMENT: commentReplyData[KEY_COMMENT],
          // KEY_LASTCOMMENTOR: commentReplyData[KEY_USERNAME],
          // KEY_LASTCOMMENTTIME: commentReplyData[KEY_COMMENTTIME],
        });

        // book의 전체 comment 개수에 commentReply개수도 더하기
        var numOfCommentsData = bookSnapshot.data() as Map;
        int numOfComments = numOfCommentsData[KEY_NUMOFCOMMENTS];
        await transaction.update(bookRef, {KEY_NUMOFCOMMENTS: numOfComments + 1});
      }
    });
  }

  Stream<List<CommentModel>> fetchAllCommentsOfBook(String bookKey) {
    return FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey).collection(COL_COMMENTS).orderBy(KEY_COMMENTTIME, descending: false).snapshots().transform(toComments);
  }

  Stream<List<CommentReplyModel>> fetchAllCommentRepliesOfBook(String bookKey, String commentKey) {
    return FirebaseFirestore.instance
        .collection(COL_BOOKS)
        .doc(bookKey)
        .collection(COL_COMMENTS)
        .doc(commentKey)
        .collection(COL_COMMENTREPLY)
        .orderBy(KEY_COMMENTREPLYTIME, descending: false)
        .snapshots()
        .transform(toCommentReplies);
  }

  void deleteComment(String bookKey, String commentKey) async {
    final delRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey).collection(COL_COMMENTS).doc(commentKey);
    delRef.delete();

    final bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);

    final DocumentSnapshot bookSnapshot = await bookRef.get();
    var bookSnapshotToMap = bookSnapshot.data() as Map;
    int numOfComments = bookSnapshotToMap[KEY_NUMOFCOMMENTS];

    bookRef.update({KEY_NUMOFCOMMENTS: numOfComments - 1});
  }

  void deleteCommentReply(String bookKey, String commentKey, String commentReplyKey) async {
    final delRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey).collection(COL_COMMENTS).doc(commentKey).collection(COL_COMMENTREPLY).doc(commentReplyKey);
    delRef.delete();

    final bookRef = FirebaseFirestore.instance.collection(COL_BOOKS).doc(bookKey);
    final commentRef = bookRef.collection(COL_COMMENTS).doc(commentKey);

    final DocumentSnapshot commentSnapshot = await commentRef.get();
    var commentSnapshotToMap = commentSnapshot.data() as Map;
    int numOfCommentReplies = commentSnapshotToMap[KEY_NUMOFCOMMENTREPLIES];

    commentRef.update({KEY_NUMOFCOMMENTREPLIES: numOfCommentReplies - 1});

    final DocumentSnapshot bookSnapshot = await bookRef.get();
    var numOfCommentsData = bookSnapshot.data() as Map;
    int numOfComments = numOfCommentsData[KEY_NUMOFCOMMENTS];
    bookRef.update({KEY_NUMOFCOMMENTS: numOfComments - 1});
  }
}

CommentNetworkRepository commentNetworkRepository = CommentNetworkRepository();

  // Future<void> createNewComment(
  //     String itemKey, Map<String, dynamic> commentData) async {
  //   final DocumentReference itemRef =
  //       FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);
  //   final DocumentSnapshot itemSnapshot = await itemRef.get();
  //   final DocumentReference commentRef = itemRef.collection(COL_COMMENTS).doc();

  //   return FirebaseFirestore.instance.runTransaction((transaction) async {
  //     if (itemSnapshot.exists) {
  //       await transaction.set(commentRef, commentData);

  //       var numOfCommentsData = itemSnapshot.data() as Map;
  //       int numOfComments = numOfCommentsData[KEY_NUMOFCOMMENTS];
  //       await transaction.update(itemRef, {
  //         KEY_NUMOFCOMMENTS: numOfComments + 1,
  //         KEY_LASTCOMMENT: commentData[KEY_COMMENT],
  //         KEY_LASTCOMMENTOR: commentData[KEY_USERNAME],
  //         KEY_LASTCOMMENTTIME: commentData[KEY_COMMENTTIME],
  //       });
  //     }
  //   });
  // }

  // Stream<List<CommentModel>> fetchAllComments(String itemKey) {
  //   return FirebaseFirestore.instance
  //       .collection(COL_ITEMS)
  //       .doc(itemKey)
  //       .collection(COL_COMMENTS)
  //       .orderBy(KEY_COMMENTTIME, descending: true)
  //       .snapshots()
  //       .transform(toComments);
  // }
  // void deleteComment(
  //     String itemKey, String commentKey, ItemModel itemModel) async {
  //   final delRef = FirebaseFirestore.instance
  //       .collection(COL_ITEMS)
  //       .doc(itemKey)
  //       .collection(COL_COMMENTS)
  //       .doc(commentKey);
  //   delRef.delete();

  //   final itemRef =
  //       FirebaseFirestore.instance.collection(COL_ITEMS).doc(itemKey);

  //   final DocumentSnapshot itemSnapshot = await itemRef.get();
  //   var itemSnapshotToMap = itemSnapshot.data() as Map;
  //   int numOfComments = itemSnapshotToMap[KEY_NUMOFCOMMENTS];

  //   itemRef.update({KEY_NUMOFCOMMENTS: numOfComments - 1});
  // }