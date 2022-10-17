import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';

class CommentModel {
  final String username;
  final String userKey;
  final String comment;
  final DateTime commentTime;
  final int numOfcommentReplies;
  final String commentKey;
  final DocumentReference reference;

  CommentModel.fromMap(
      Map<String, dynamic> map, this.commentKey, this.reference)
      : username = map[KEY_USERNAME],
        userKey = map[KEY_USERKEY],
        comment = map[KEY_COMMENT],
        numOfcommentReplies = map[KEY_NUMOFCOMMENTREPLIES],
        commentTime = map[KEY_COMMENTTIME] == null
            ? DateTime.now().toUtc()
            : (map[KEY_COMMENTTIME] as Timestamp).toDate();

  CommentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        );

  static Map<String, dynamic> getMapForNewComment(
      String userKey, String username, String comment) {
    Map<String, dynamic> map = Map();
    map[KEY_USERNAME] = username;
    map[KEY_USERKEY] = userKey;
    map[KEY_COMMENT] = comment;
    map[KEY_NUMOFCOMMENTREPLIES] = 0;
    map[KEY_COMMENTTIME] = DateTime.now().toUtc();
    return map;
  }
}
