import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/item_service.dart';

class BookDetailScreenList extends StatelessWidget {
  BookDetailScreenList({Key? key}) : super(key: key);

  BookModel bookModel = Get.arguments;

  final String bookKey = Get.parameters['bookKey']!;

  @override
  Widget build(BuildContext context) {
    final itemKeys = bookModel.bookItems;
    return Scaffold(
      appBar: AppBar(
        title: Text('${bookModel.bookTitle}'),
      ),
      body: FutureBuilder<List<ItemModel>>(
          future: ItemService().getSomeItemsByItemKeys(itemKeys),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<ItemModel> bookItems = snapshot.data!;

              return ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: bookItems.length,
                      itemBuilder: (context, index) {
                        ItemModel bookItem = bookItems[index];
                        return Container(
                          // height: 120,
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(10),
                          //   shape: BoxShape.rectangle,
                          // ),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: common_l_gap),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${bookItem.question}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'SDneoR'),
                                            ),
                                            Text(
                                              '${categoriesMapEngToKor[bookItem.category]}',
                                              style: TextStyle(
                                                color: Colors.blue,
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
                                    (bookItem.imageDownloadUrls.isNotEmpty)
                                        ? ExtendedImage.network(
                                            bookItem.imageDownloadUrls[0],
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
                                                  style: TextStyle(
                                                      color: Colors.grey),
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
                        );
                      }),
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
