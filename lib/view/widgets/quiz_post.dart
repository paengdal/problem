import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
import 'package:quiz_first/view/screens/input_screen.dart';
import 'package:quiz_first/view/widgets/options.dart';
import 'package:quiz_first/view/widgets/quiz_post_deep.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

import '../screens/comments_screen.dart';

class QuizPost extends StatefulWidget {
  final List<ItemModel> itemModels;
  const QuizPost({Key? key, required this.itemModels}) : super(key: key);

  @override
  State<QuizPost> createState() => _QuizPostState();
}

class _QuizPostState extends State<QuizPost> {
  @override
  Widget build(BuildContext context) {
    if (widget.itemModels.isNotEmpty) {
      return ListView.builder(
        reverse: true,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.itemModels.length,
        itemBuilder: (context, index) {
          var itemModel = widget.itemModels[index];
          return QuizPostDeep(
              itemModels: widget.itemModels,
              itemModel: itemModel,
              postIndex: index);
        },
      );
    } else {
      return Center(child: CircularProgressIndicator());
      // return Column(
      //   children: [
      //     SizedBox(
      //       height: 100,
      //     ),
      //     Container(
      //       child: Text(
      //         '새로운 문제가 없습니다.',
      //         style: TextStyle(color: Colors.grey[400], fontSize: 20),
      //       ),
      //     ),
      //     Container(
      //       child: Text(
      //         '문제를 만들어 주세요.',
      //         style: TextStyle(color: Colors.grey[400], fontSize: 20),
      //       ),
      //     ),
      //     SizedBox(
      //       height: 40,
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         Get.to(() => InputScreen(), fullscreenDialog: true);
      //       },
      //       child: Text('문제 만들기'),
      //       style: ElevatedButton.styleFrom(primary: Colors.teal, elevation: 0),
      //     ),
      //   ],
      // );
    }
  }
}
