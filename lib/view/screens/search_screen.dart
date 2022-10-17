import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/input_deco.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/repo/algolia_service.dart';
import 'package:quiz_first/repo/book_service.dart';

class SearchScreen extends StatefulWidget {
  final arguments;
  SearchScreen({Key? key, this.arguments}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<BookModel> _books = [];
  bool isProcessing = false;
  final TextEditingController _textEditingController = TextEditingController();
  final userKey = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left),
          // constraints: BoxConstraints(),
          iconSize: 22,
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Get.back();
            _books.clear();
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextFormField(
            controller: _textEditingController,
            autofocus: true,
            decoration: textInputDecoSearch('문제 검색'),
            onFieldSubmitted: (value) async {
              isProcessing = true;
              setState(() {});
              List<BookModel> newBooks =
                  await AlgoliaService().queryBooks(value);
              if (newBooks.isNotEmpty) {
                _books.clear();
                _books.addAll(newBooks);
              }
              isProcessing = false;
              setState(() {});
            },
          ),
        ),
        titleSpacing: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.green, // <-- SEE HERE
          statusBarIconBrightness:
              Brightness.dark, //<-- For Android SEE HERE (dark icons)
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: ListView(
        children: [
          if (isProcessing)
            LinearProgressIndicator(
              minHeight: 2,
            ),
          SizedBox(
            height: 10,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              BookModel book = _books[index];
              return InkWell(
                // splashColor: Colors.transparent,
                onTap: () {
                  // 이미 푼 문제인지 체크
                  var userKeys = [];
                  for (int i = 0; i < book.solvedUsersAndScore.length; i++) {
                    userKeys.add(book.solvedUsersAndScore[i].userKey);
                  }
                  if (!(userKeys.contains(userKey))) {
                    Get.toNamed('/bookDetail/${book.bookKey}', arguments: book);
                  } else {
                    Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        content: Text(
                            '이미 푼 문제집입니다. 다시 풀더라도 최초에 기록된 점수는 갱신되지 않습니다. 그래도 다시 풀어보시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed('/bookDetail/${book.bookKey}',
                                  arguments: book);
                            },
                            child: Text('다시 풀기'),
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
                  }
                },
                onLongPress: () {
                  Get.dialog(
                    barrierDismissible: false,
                    AlertDialog(
                      content: Text('문제집을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            BookService().deleteBook(_books, book, index,
                                FirebaseAuth.instance.currentUser!.uid);
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      common_m_gap, 0, common_m_gap, 0),
                  child: Container(
                    // height: 120,
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(10),
                    //   shape: BoxShape.rectangle,
                    // ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: common_xxs_gap),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${book.bookTitle}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'SDneoSB'),
                                      ),
                                      Text(
                                        '${book.bookDesc}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              (book.imageDownloadUrls.isNotEmpty)
                                  ? ExtendedImage.network(
                                      book.imageDownloadUrls[0],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                        ),
                                        Positioned(
                                          left: 13,
                                          top: 30,
                                          child: Text(
                                            'no image',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                            height: 27,
                            indent: 0,
                            endIndent: 90,
                            color: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: _books.length,
          ),
        ],
      ),
    );
  }
}
