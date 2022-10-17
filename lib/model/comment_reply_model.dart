import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/constants/firestore_keys.dart';

class CommentReplyModel {
  final String username;
  final String userKey;
  final String commentReply;
  final DateTime commentReplyTime;
  final String commentReplyKey;
  final String commentReOfRename;
  final DocumentReference reference;

  CommentReplyModel.fromMap(Map<String, dynamic> map, this.commentReplyKey, this.reference)
      : username = map[KEY_USERNAME],
        userKey = map[KEY_USERKEY],
        commentReply = map[KEY_COMMENTREPLY],
        commentReOfRename = map[KEY_COMMENTREOFRENAME],
        commentReplyTime = map[KEY_COMMENTREPLYTIME] == null ? DateTime.now().toUtc() : (map[KEY_COMMENTREPLYTIME] as Timestamp).toDate();

  CommentReplyModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromMap(
          snapshot.data()!,
          snapshot.id,
          snapshot.reference,
        );

  static Map<String, dynamic> getMapForNewCommentReply(String userKey, String username, String commentReply, String name) {
    Map<String, dynamic> map = Map();
    map[KEY_USERNAME] = username;
    map[KEY_USERKEY] = userKey;
    map[KEY_COMMENTREPLY] = commentReply;
    map[KEY_COMMENTREOFRENAME] = name;
    map[KEY_COMMENTREPLYTIME] = DateTime.now().toUtc();
    return map;
  }
}
