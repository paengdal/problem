import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/model/item_model.dart';

class MySolvedItemList extends StatelessWidget {
  const MySolvedItemList({
    Key? key,
    required List<ItemModel> myItems,
  })  : _myItems = myItems,
        super(key: key);

  final List<ItemModel> _myItems;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _myItems.length,
      itemBuilder: (BuildContext context, int index) {
        var myItem = _myItems[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(common_m_gap, 0, common_m_gap, 0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${myItem.question}',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'SDneoR'),
                              ),
                              Text(
                                '${categoriesMapEngToKor[myItem.category]}',
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
                      (myItem.imageDownloadUrls.isNotEmpty)
                          ? ExtendedImage.network(
                              myItem.imageDownloadUrls[0],
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
                                    style: TextStyle(color: Colors.grey),
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
        );
      },
    );
  }
}
