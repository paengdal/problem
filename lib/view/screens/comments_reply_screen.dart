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
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class CommentsReplyScreen extends StatefulWidget {
  final bookKey;
  final comment;
  final commentReplyKey;
  final reOfReName;
  const CommentsReplyScreen({
    Key? key,
    this.bookKey,
    this.comment,
    this.commentReplyKey,
    this.reOfReName,
  }) : super(key: key);

  @override
  State<CommentsReplyScreen> createState() => _CommentsReplyScreenState();
}

class _CommentsReplyScreenState extends State<CommentsReplyScreen> {
  TextEditingController _commmentReplyController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commmentReplyController.dispose();
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
          '답글쓰기',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 댓글 리스트
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        StreamProvider<UserModel?>.value(
                          value: userNetworkRepository.getUserModelStream(widget.comment.userKey),
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
                                                Text(
                                                  '${userModel.username}',
                                                  style: TextStyle(fontFamily: 'SDneoB', fontSize: 15),
                                                ),
                                                Text(
                                                  '${widget.comment.comment}',
                                                  style: TextStyle(fontSize: 15, color: Colors.black87),
                                                  // overflow: TextOverflow.ellipsis,
                                                  // maxLines: 1,
                                                ),
                                                Text(
                                                  '${TimeCalculation.getToday(widget.comment.commentTime)}',
                                                  style: TextStyle(fontSize: 13, color: Colors.grey),
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
                                        value: commentNetworkRepository.fetchAllCommentRepliesOfBook(widget.bookKey, widget.comment.commentKey),
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
                                                                            Text(
                                                                              '${userModel.username}',
                                                                              style: TextStyle(fontFamily: 'SDneoB', fontSize: 15),
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
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
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
                        autofocus: true,
                        controller: _commmentReplyController,
                        cursorColor: Colors.black54,
                        decoration: InputDecoration(
                          hintText: '답글 입력...',
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
                        Map<String, dynamic> newCommentReply = CommentReplyModel.getMapForNewCommentReply(userModel.userKey, userModel.username, _commmentReplyController.text, widget.reOfReName);
                        await commentNetworkRepository.createNewCommentReply(widget.bookKey, newCommentReply, widget.comment.commentKey);
                        _commmentReplyController.clear();
                      }
                      Get.back();
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
