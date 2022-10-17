import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/constants/input_deco.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/comment_reply_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/time_calculation.dart';
import 'package:quiz_first/view/screens/comments_reply_screen.dart';
import 'package:quiz_first/view/screens/test_screen.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class CommentsScreen extends StatefulWidget {
  final bookKey;
  const CommentsScreen({
    Key? key,
    this.bookKey,
  }) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _commmentController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _reOfRE = false;

  @override
  void dispose() {
    _commmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          // constraints: BoxConstraints(),
          iconSize: 22,
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          '댓글 보기',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 댓글 리스트
              Expanded(
                child: StreamProvider<List<CommentModel>>.value(
                  value: commentNetworkRepository.fetchAllCommentsOfBook(widget.bookKey),
                  initialData: [],
                  child: Consumer<List<CommentModel>>(
                    builder: (context, comments, child) {
                      return ListView(
                        // shrinkWrap: true,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return StreamProvider<UserModel?>.value(
                                value: userNetworkRepository.getUserModelStream(comments[index].userKey),
                                // comments값이 필요하기때문에 상위에 multiprovider를 쓸 수가 없다.
                                initialData: null,
                                child: Consumer<UserModel?>(
                                  builder: (BuildContext context, UserModel? userModel, Widget? child) {
                                    if (userModel != null) {
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(common_m_gap, 0, common_xxs_gap, 0),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RoundedAvatar(
                                                  avatarSize: 30,
                                                  userModel: userModel,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        // mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${userModel.username}',
                                                              style: TextStyle(fontFamily: 'SDneoB', fontSize: 15),
                                                            ),
                                                          ),
                                                          (context.read<UserModelState>().userModel!.userKey == comments[index].userKey)
                                                              ? IconButton(
                                                                  constraints: BoxConstraints(),
                                                                  padding: EdgeInsets.all(2),
                                                                  iconSize: 16,
                                                                  onPressed: () {
                                                                    Get.dialog(
                                                                      barrierDismissible: false,
                                                                      AlertDialog(
                                                                        content: Text('댓글을 삭제하시겠습니까?'),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              commentNetworkRepository.deleteComment(
                                                                                widget.bookKey,
                                                                                comments[index].commentKey,
                                                                              );

                                                                              Get.back();
                                                                            },
                                                                            child: Text(
                                                                              '삭제',
                                                                              style: TextStyle(color: Colors.red),
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Get.back();
                                                                            },
                                                                            child: Text('취소'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  icon: Icon(
                                                                    CupertinoIcons.multiply,
                                                                    color: Colors.red,
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${comments[index].comment}',
                                                        style: TextStyle(fontSize: 15, color: Colors.black87),
                                                        // overflow: TextOverflow.ellipsis,
                                                        // maxLines: 1,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '${TimeCalculation.getToday(comments[index].commentTime)}',
                                                            style: TextStyle(fontSize: 13, color: Colors.grey),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Get.to(() => CommentsReplyScreen(
                                                                    bookKey: widget.bookKey,
                                                                    comment: comment,
                                                                    reOfReName: '',
                                                                  ));
                                                            },
                                                            child: Text(
                                                              ' • 답글쓰기',
                                                              style: TextStyle(fontSize: 13, color: Colors.grey),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: common_xxxs_gap),
                                              child: Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: Colors.grey[200],
                                              ),
                                            ),

                                            // 답글(대댓글) 목록
                                            StreamProvider<List<CommentReplyModel>>.value(
                                              initialData: [],
                                              value: commentNetworkRepository.fetchAllCommentRepliesOfBook(widget.bookKey, comment.commentKey),
                                              child: Consumer<List<CommentReplyModel>>(
                                                builder: (BuildContext context, List<CommentReplyModel> commentReplies, Widget? child) {
                                                  return Padding(
                                                    padding: commentReplies.length != 0 ? const EdgeInsets.only(top: 10) : const EdgeInsets.all(0),
                                                    child: ListView.separated(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemBuilder: (context, index) {
                                                          CommentReplyModel commentReply = commentReplies[index];
                                                          final userKey = commentReply.userKey;

                                                          return StreamProvider<UserModel?>.value(
                                                            initialData: null,
                                                            value: userNetworkRepository.getUserModelStream(userKey),
                                                            child: Consumer<UserModel?>(
                                                              builder: (BuildContext context, UserModel? userModel, Widget? child) {
                                                                if (userModel != null) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets.fromLTRB(common_xxl_gap, 0, 0, 0),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            RoundedAvatar(
                                                                              avatarSize: 26,
                                                                              userModel: userModel,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Text(
                                                                                          '${userModel.username}',
                                                                                          style: TextStyle(fontFamily: 'SDneoB', fontSize: 15),
                                                                                        ),
                                                                                      ),
                                                                                      (context.read<UserModelState>().userModel!.userKey == commentReply.userKey)
                                                                                          ? IconButton(
                                                                                              constraints: BoxConstraints(),
                                                                                              padding: EdgeInsets.all(2),
                                                                                              iconSize: 16,
                                                                                              onPressed: () {
                                                                                                Get.dialog(
                                                                                                  barrierDismissible: false,
                                                                                                  AlertDialog(
                                                                                                    content: Text('답글을 삭제하시겠습니까?'),
                                                                                                    actions: [
                                                                                                      TextButton(
                                                                                                        onPressed: () {
                                                                                                          commentNetworkRepository.deleteCommentReply(
                                                                                                              widget.bookKey, comment.commentKey, commentReply.commentReplyKey);
                                                                                                          Get.back();
                                                                                                        },
                                                                                                        child: Text(
                                                                                                          '삭제',
                                                                                                          style: TextStyle(color: Colors.red),
                                                                                                        ),
                                                                                                      ),
                                                                                                      TextButton(
                                                                                                        onPressed: () {
                                                                                                          Get.back();
                                                                                                        },
                                                                                                        child: Text('취소'),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                );
                                                                                              },
                                                                                              icon: Icon(
                                                                                                CupertinoIcons.multiply,
                                                                                                color: Colors.red,
                                                                                              ),
                                                                                            )
                                                                                          : Container(),
                                                                                    ],
                                                                                  ),
                                                                                  RichText(
                                                                                    text: TextSpan(
                                                                                      children: [
                                                                                        TextSpan(
                                                                                          text: commentReply.commentReOfRename != '' ? '${commentReply.commentReOfRename} ' : '',
                                                                                          style: TextStyle(fontSize: 15, color: Colors.blue[600], fontFamily: 'SDneoSB'),
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: '${commentReplies[index].commentReply}',
                                                                                          style: TextStyle(fontSize: 15, color: Colors.black87),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        '${TimeCalculation.getToday(commentReplies[index].commentReplyTime)}',
                                                                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                                                                      ),
                                                                                      GestureDetector(
                                                                                        onTap: () {
                                                                                          Get.to(() => CommentsReplyScreen(
                                                                                                bookKey: widget.bookKey,
                                                                                                comment: comment,
                                                                                                // commentReplyKey: commentReply.commentReplyKey,
                                                                                                reOfReName: commentReply.username,
                                                                                              ));
                                                                                        },
                                                                                        child: Text(
                                                                                          ' • 답글쓰기',
                                                                                          style: TextStyle(fontSize: 13, color: Colors.grey),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height: 10,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(right: common_xxxs_gap),
                                                                          child: Divider(
                                                                            height: 1,
                                                                            thickness: 1,
                                                                            color: Colors.grey[200],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Container();
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        separatorBuilder: (context, index) {
                                                          return SizedBox(
                                                            height: 10,
                                                          );
                                                        },
                                                        itemCount: commentReplies.length),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 10,
                              );
                            },
                            itemCount: comments == null ? 0 : comments.length,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // 댓글 입력창 시작
              Divider(
                height: 1,
                thickness: 1,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                      child: TextFormField(
                        autofocus: false,
                        controller: _commmentController,
                        cursorColor: Colors.black54,
                        decoration: InputDecoration(
                          hintText: '댓글 입력...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return '내용을 입력하세요';
                          }
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        UserModel userModel = context.read<UserModelState>().userModel!;
                        Map<String, dynamic> newComment = CommentModel.getMapForNewComment(userModel.userKey, userModel.username, _commmentController.text);
                        await commentNetworkRepository.createNewComment(widget.bookKey, newComment);
                        _commmentController.clear();
                      }
                    },
                    child: Text('등록'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
