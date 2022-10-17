import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/view/screens/feed/book_detail_screen.dart';
import 'package:quiz_first/view/widgets/book_post_deep.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class BookPost extends StatefulWidget {
  final List<BookModel> bookModels;
  const BookPost({Key? key, required this.bookModels}) : super(key: key);

  @override
  State<BookPost> createState() => _BookPostState();
}

class _BookPostState extends State<BookPost> {
  final sizedBoxH = SizedBox(
    height: 10,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.bookModels.isNotEmpty) {
      return ListView.builder(
        reverse: true,
        itemCount: widget.bookModels.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var bookModel = widget.bookModels[index];
          return BookPostDeep(
            bookModel: bookModel,
            bookModels: widget.bookModels,
            postIndex: index,
          );
        },
      );
    } else {
      return Container();
    }
  }
}
